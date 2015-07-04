debug = require("debug")("images")
request = require "request"
module.exports = (db) ->
  return (req,res,next) ->
    return res.status(404).end() unless req.params
    db.collection("Images").findOne {
      displayId: req.params.id
    } , (err,results) ->
      debug results
      if err
        res.status(500).json(err).end()
      else if not results
        res.status(404).end()
      else
        if req.params.ext in [".jpg",".png"]
          request("http://assets.bullbones.pics/#{results.name}").pipe(res).on "error", (err) ->
            debug err
            res.status(500).send(err).end()
        else if not req.params.ext
          res.render "images", {image: results}