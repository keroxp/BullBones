debug = require("debug")("export")
###
  var buffer: Dynamic;    //null
  var encoding: String;   //"7bit"
  var extension: String;  //"png"
  var fieldname: String;  //"file"
  var mimetype: String;   //"image/png"
  var name: String;       //"b705411a93ac5a16ffe1b2e0c2acdf13.png"
  var originalname: String; //"image.png"
  var path: String;       //"uploads/b705411a93ac5a16ffe1b2e0c2acdf13.png"
  var size:  Int;         //218929
  var truncated: Bool;    //false
###

module.exports = (db) ->
  return (req,res) ->
    if not req.body or not req.body.name
      return res.status(400).send("body is incomplete.").end()
    file = req.body
    image =
      extension: file.extension
      name: file.name
      path: file.path
      mimetype: file.mimetype
      encoding: file.encoding
      displayId: file.name.split(".")[0]
      size: file.size
      createdAt: new Date()
      host: (process.env.ASSETS_SERVER_HOST || 'localhost:8001')
    db.collection("Images").insert image, (err, results) ->
      if err
        res.status(500).json(err).end()
      else
        res.json(image).end()