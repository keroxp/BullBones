Canvas = require "canvas"
Image = Canvas.Image
path = require "path"
NodeCache = require "node-cache"
canvas = new Canvas
cache = new NodeCache(stdTTL: 100, checkperiod: 120, useClones: false)

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
  category = req.query.category
  name = req.query.name
  sx = req.query.sx
  sy = req.query.sy
  width = req.query.width
  height = req.query.height
  scale = req.query.scale || 1.0
  if undefined in [category,name,sx,sy,width,height]
    return res.status(400).send("one or more rquired parameter(s) were not given").end()
  name = path.parse(name).name
  sx |= 0
  sy |= 0
  width |= 0
  height |= 0
  scale = parseFloat(scale)
  imgpath = "#{category}/#{name}"
  imgurl = "#{process.env.CoherentLinesPath || './cohlines'}/#{imgpath}.jpg"
  onload = (img) ->
    ->
      if sx < 0 or sy < 0 or img.width < sx+width or img.height < sy+height
        return res.status(400).send("given bounds exceeds original images, orig => {#{img.width}, #{img.height}}").end()
      cache.set(imgpath, img)
      canvas.width = width*scale
      canvas.height = height*scale
      ctx = canvas.getContext "2d"
      ctx.drawImage img, sx, sy, width, height, 0, 0, canvas.width, canvas.height
      res.set 'Content-Type', 'image/png'
      res.send canvas.toBuffer()
      res.end()
  if cachedImg = cache.get imgpath
    onload(cachedImg)()
  else
    img = new Image
    img.onload = onload(img)
    img.onerror = ->
      res.status(404).send("line image #{category}/#{name}.jpg was not found.").end()
    img.src = imgurl
