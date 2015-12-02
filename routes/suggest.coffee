debug = require("debug")("suggest")
fs = require("fs")
base64 = require "urlsafe-base64"
async = require "async"
Canvas = require "canvas"
Image = Canvas.Image
canvas = new Canvas(64,64)
{Rect} = require "../utils/geometry"
ctx = canvas.getContext("2d")
hashfunc = require "../utils/hashfunc"
_ = require "lodash"
###
  Coherent Line Suggestion
  @param connection MySQLのコネクションオブジェクト
###
module.exports = (connection) ->
  parseDataURL = (dataURL) ->
    arr = dataURL.split ","
    return false if arr.length < 2
    return base64.decode(arr[1])
  ###
  Suggestion API
  @param dataURL dataURL化されたJPEG画像
  ###
  return (req,res) ->
    url = req.body.dataURL
    if not req.body.dataURL
      return res.status(400).send("dataURL was not given.")
    buf = parseDataURL url
    if not buf
      return res.status(400).send("dataURL was invalid")
    img = new Image
    img.onload = ->
      w = if img.width > img.height then 64 else 64*(img.width/img.height) | 0
      h = if img.height > img.width then 64 else 64*(img.height/img.width) | 0
      x = (64-w)*.5 | 0
      y = (64-h)*.5 | 0
      ctx.clearRect(0,0,64,64)
      ctx.drawImage(img,0,0,img.width,img.height,x,y,w,h)
      fs.writeFileSync "tmp/test.png", canvas.toBuffer()
      imgdata = ctx.getImageData(0,0,64,64)
      iw = imgdata.width
      ih = imgdata.height
      flags = []
      for y in [0..ih-1]
        for x in [0..iw-1]
          i = (y*iw+x)*4
          r = imgdata.data[i]
          g = imgdata.data[i+1]
          b = imgdata.data[i+2]
          a = imgdata.data[i+3]
          if a > 0 and (r != 255 && g != 255 && b != 255)
            flags.push(y*iw+x)
      query = "SELECT Images.*, CoherentLines.* FROM `MinHashes`, `CoherentLines`, `Images` WHERE"
      query += " ("
      for n in [0..9]
        sketches = []
        for k in [0..2]
          min = hashfunc("#{n}-#{k}-#{flags[0]}")
          for b in flags
            m = hashfunc("#{n}-#{k}-#{b}")
            min = m if m < min
          sketches.push(min)
        seed = sketches.join ','
        sketchHash = hashfunc(seed)
        query += " (MinHashes.hash_func_index = '#{n}' AND MinHashes.sketch_hash = '#{sketchHash}') "
        if n != 9
          query += "OR"
        else
          query += " )"
      query += " AND MinHashes.line_id = CoherentLines.id"
      query += " AND CoherentLines.image_id = Images.id"
      query += ";"
      debug query
      opts =
        sql: query
        nestTables: true
      connection.query opts, (err,results,fields) ->
        debug err if err
        res.status(200).json(results).end()
    img.onerror = (err) ->
      res.status(400).send(err).end()
    img.src = buf
