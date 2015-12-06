debug = require("debug")("suggest")
fs = require("fs")
base64 = require "urlsafe-base64"
async = require "async"
Canvas = require "canvas"
Image = Canvas.Image
canvas = new Canvas(64,64)
{Rect} = require "../utils/geometry"
hashfunc = require "../utils/hashfunc"
async = require "async"
_ = require "lodash"
loader = require "../utils/image_loader"
parseDataURL = (dataURL) ->
  arr = dataURL.split ","
  return false if arr.length < 2
  return base64.decode(arr[1])

###
  Coherent Line Suggestion
  @param connection MySQLのコネクションオブジェクト
###
module.exports = (connection) ->
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
      canvas.width = 64
      canvas.height = 64
      ctx = canvas.getContext("2d")
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
      query = "
        SELECT CoherentLines.*, BaseCohrentLine.*, Images.* FROM CoherentLines
        INNER JOIN NearLines ON NearLines.target_line_id = CoherentLines.id
        INNER JOIN MinHashes ON MinHashes.line_id = NearLines.line_id
        LEFT OUTER JOIN CoherentLines AS BaseCohrentLine ON MinHashes.line_id = BaseCohrentLine.id
        INNER JOIN Images ON CoherentLines.image_id = Images.id
        WHERE
      "
      for n in [0..9]
        sketches = []
        for k in [0..2]
          min = hashfunc("#{n}-#{k}-#{flags[0]}")
          for b in flags
            m = hashfunc("#{n}-#{k}-#{b}")
            min = m if m < min
          sketches.push(min)
        sketchHash = hashfunc(sketches.join(','))
        query += "(MinHashes.hash_func_index = '#{n}' AND MinHashes.sketch_hash = '#{sketchHash}') "
        query += "OR " if n != 9
      query += ";"
      debug query
      opts =
        sql: query
        nestTables: true
      async.waterfall [
        (done) ->
          connection.query opts, (err,results,fields) ->
            debug err if err
            done err, results
        (results, done) ->
          return done() if results.length == 0
          imgs = _.chain(results)
            .map (r) -> r.Images
            .uniq (r) ->  r.id
            .value()
          bounds = new Rect(0,0,img.width,img.height)
          memo = {}
          async.each imgs, (img, done2) ->
            loader.promiseImage(img.category,img.name)
            .then (loaded) ->
              memo["#{img.category}/#{img.name}"] = loaded
              done2 null, memo
            .catch done2
          , (err) ->
            if err
              debug err
              return done(err)
            data = _.chain(results)
            .each (v) ->
              scx = img.width / v.CoherentLines.width
              scy = img.height / v.CoherentLines.height
              sc = Math.min(scx,scy)
              dx = v.CoherentLines.sx - v.BaseCohrentLine.sx
              dy = v.CoherentLines.sy - v.BaseCohrentLine.sy
              w = v.CoherentLines.width
              h = v.CoherentLines.height
              bounds.extend(dx*sc,dy*sc,w*sc,h*sc)
            .value()
            canvas.width = bounds.width
            canvas.height = bounds.height
            ctx = canvas.getContext "2d"
            for v in data
              cl = v.CoherentLines
              bl = v.BaseCohrentLine
              scx = img.width / cl.width
              scy = img.height / cl.height
              sc = Math.min(scx,scy)
              dx = cl.sx - bl.sx
              dy = cl.sy - bl.sy
              x = dx * sc - bounds.x
              y = dy * sc - bounds.y
              srcimg = memo["#{v.Images.category}/#{v.Images.name}"]
              cohimg = loader.sliceImage(srcimg,cl.tiled_sx,cl.tiled_sy,cl.width,cl.height,sc,sc)
              ctx.drawImage cohimg, x, y
            done err, {
              bounds: bounds
              pivX: -bounds.x
              pivY: -bounds.y
              dataURL: canvas.toDataURL()
            }
      ] , (err,result) ->
        if err
          res.status(500).send(err).end()
        else if not result
          res.status(200).json({
            code: 0x00
            error: "Ghost was not generated because no similar line was found."
          }).end()
        else
          res.status(200).json(result).end()
    img.onerror = (err) ->
      res.status(400).send(err).end()
    img.src = buf
