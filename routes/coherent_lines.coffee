path = require "path"
NodeCache = require "node-cache"
cache = new NodeCache(stdTTL: 100, checkperiod: 120, useClones: false)
loader = require "../utils/image_loader"
debug = require("debug")("coherent_lines")
###
  Coherent Line API
  @param category String
  @param name String
  @param sx Number
  @param sy Number
  @param width Number
  @param height Number
  @param @optional scale Number default: 1.0
###
module.exports = (req,res) ->
  q = req.query
  category = q.category
  name = q.name
  if not category or not name
    return res.status(400).send("category or name was not given").end()
  name = path.parse(name).name
  imgpath = "#{category}/#{name}"
  done = (img) ->
    cache.set(imgpath,img)
    try
      canvas = loader.sliceImage(img,q.sx,q.sy,q.width,q.height)
      res.status(200).set('Content-Type', 'image/png').send(canvas.toBuffer()).end()
    catch e
      res.status(400).send(e).end()
  if img = cache.get(imgpath)
    done img
  else
    base = process.env.ResourcePath || "res"
    url = "#{base}/#{category}/#{name}/lines.png"
    loader.promiseImage(url)
      .then done
      .catch res.status(404).send("image #{imgpath} was not found or an error occured while loading").end()
