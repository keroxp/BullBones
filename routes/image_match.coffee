debug = require("debug")("image_match")
Canvas = require "canvas"
Image = Canvas.Image
canvas = new Canvas
Cache = require "node-cache"
cache = new Cache stdTTL: 100, checkperiod: 120, useClones: false
loader = require "../utils/image_loader"
async = require "async"
imgutil = require "../utils/images"
path = require "path"
###
  @param connection MySQL connection
###
module.exports = (connection) ->
  ###
    image_match API
    @param @required line_id CoherentLines id
    @return png image
  ###
  (req,res) ->
    line_id = req.query.line_id
    query =
      "SELECT * FROM CoherentLines
      INNER JOIN Images ON Images.id = CoherentLines.image_id
      WHERE CoherentLines.id = #{line_id} LIMIT 1;"
    debug query
    connection.query {sql: query, nestTables: true}, (err, results) ->
      if results  && results.length > 0
        r = results[0]
        imgpath = "#{r.Images.category}/#{r.Images.name}"
        onload = (images) ->
          cache.set imgpath, images
          thumb = images[0]
          lines = images[1]
          cohl = r.CoherentLines
          line = loader.sliceImage(lines,cohl.tiled_sx,cohl.tiled_sy,cohl.width,cohl.height)
          if line.width == 0 or line.height == 0
            return res.status(500).send("given coherent line's width or height is 0").end()
          canvas.width = thumb.width
          canvas.height = thumb.height
          ctx = canvas.getContext "2d"
          transLine = imgutil.map line, (args) ->
            if args.r == args.g == args.b == 255
              args.a = 0
            else
              args.r = 255
              args.g = 0
              args.b = 0
            args
          ctx.globalAlpha = 0.5
          ctx.drawImage thumb,0,0
          ctx.globalAlpha = 1.0
          ctx.drawImage transLine,0,0,transLine.width,transLine.height,cohl.sx,cohl.sy,cohl.width,cohl.height
          res.status(200).set("Content-Type","image/png").send(canvas.toBuffer()).end()
        if images = cache.get(imgpath)
          onload images
        else
          base = process.env.ResourcePath || "res"
          category = r.Images.category
          {name} = path.parse r.Images.name
          respath = path.resolve "#{base}/#{category}/#{name}"
          debug respath
          Promise.all [
            loader.promiseImage "#{respath}/thumbnail.png"
            loader.promiseImage "#{respath}/lines.png"
          ]
          .then (images) ->
            onload images
          .catch (e) ->
            debug e
            res.status(500).send(e).end()
      else
        res.status(400).send("該当するデータがありません。id = #{line_id}").end()
