debug = require("debug")("signed_url")
request = require "request"
module.exports = () ->
  return (req,res,next) ->
    uploader_url = "http://" + (process.env.ASSETS_SERVER_HOST || 'localhost:8001') + "/signed_url"
    debug uploader_url
    request.get uploader_url, (err,response,body) ->
      if err or response.statusCode isnt 200
        res.status(response.statusCode).send(err || response.statusMessage).end()
      else
        json = JSON.parse body
        debug json
        res.json(json).end()