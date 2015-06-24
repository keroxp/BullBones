request = require "request"
btoa = require "btoa"
debug = require("debug")("search")
logerr= require("debug")("app:error")
moment = require "moment"
async = require "async"

module.exports = (db) ->
  return (req,res) ->
    q = req.query.q
    unless q
      res.status(400).send("query was not provided.")
      return
    debug "search-query: "+q
    checkCache = (callback) ->
      db.collection("BingCaches").findOne
       query: q
      , (err, cache) ->
        if err
          callback err
        else
          callback null, cache
    exploreBing = (cache, callback) ->
      if cache
        now = moment()
        last = moment(cache.lastUpdated,"YYYYMMDD")
        if now.diff(last,"days") < 30
          debug "cache for '#{q} was found."
          callback "break", cache.response
          return
        else
          debug "cache for '#{q} has been expired. try to re-fetch."
      unless process.env.BING_API_KEY
        callback new Error("API KEY required")
      else
        url = "https://api.datamarket.azure.com/Bing/Search/Image?$format=json&Query="
        key = process.env.BING_API_KEY
        request.put
          url: "#{url}'#{encodeURIComponent(q)}'"
          headers:
            Authorization: "Basic "+btoa(key+":"+key)
        , (err,response,body) ->
          if err or response.statusCode isnt 200
            callback(err or response.statusMessage)
          else
            images = JSON.parse(body).d.results
            if not images or images.length == 0
              callback new Error("images not found")
            else
              callback null, images
    saveCache = (images, callback) ->
      db.collection("BingCaches").update {
        query:q
      },{
        query:q
        response: images
        lastUpdated: moment().format("YYYYMMDD")
      },{
        upsert: yes
      }, (err) ->
        if err
          callback err
        else
          debug "chache for '#{q}' was saved."
          callback null, images
    done = (err, results) ->
      if err and err isnt "break"
        logerr err
        res.status(500).send(err)
      else if results
        res.json results
      else
        res.status(500).send("error")

    async.waterfall [
      checkCache,
      exploreBing,
      saveCache
    ], done


