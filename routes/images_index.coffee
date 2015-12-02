debug = require("debug")("image_index")
module.exports = (db) ->
  onError = (res, err) ->
    debug err
    res.status(500).json(err).end()
  return (req,res,next) ->
    db.collection("Images").find {}, {limit: 50, sort: {createdAt: -1}}, (err, cursor) ->
      return onError(res,err) if err
      cursor.toArray (err,images) ->
        return onError(res,err) if  err
        res.render "images_index",
          images: images
