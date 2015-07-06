debug = require("debug")("images")
request = require "request"
module.exports = (db) ->
  return (req,res,next) ->
    return res.status(404).end() unless req.params
    db.collection("Images").findOne {
      displayId: req.params.id
    } , (err,image) ->
      if err
        res.status(500).json(err).end()
      else if not image
        res.status(404).end()
      else
        if req.params.ext in [".jpg",".png"]
          if req.params.ext.match image.extension
            request("http://#{image.host}/#{image.name}").pipe(res).on "error", (err) ->
              debug err
              res.status(500).send(err).end()
          else
            res.redirect "/images/#{image.name}"
        else if not req.params.ext
          res.render "images", {image: image}