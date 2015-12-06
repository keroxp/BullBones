path = require "path"
Canvas = require "canvas"
Image = Canvas.Image
path = require "path"
canvas = new Canvas
###
  sliceImage
  @throw if
  @return Canavas that has been rendered with sliced Image
###
sliceImage = (img,sx,sy,width,height,scaleX = 1.0, scaleY = 1.0) ->
  if undefined in [img,sx,sy,width,height]
    throw new Error("one or more rquired parameter(s) were not given")
  if sx < 0 or sy < 0 or img.width < sx+width or img.height < sy+height
    throw new Error("given bounds exceeds original images, original =>
       {#{img.width}, #{img.height}}, given => {#{sx},#{sy},#{width},#{height}}")
  canvas.width = width*scaleX
  canvas.height = height*scaleY
  ctx = canvas.getContext "2d"
  ctx.drawImage img, sx, sy, width, height, 0, 0, canvas.width, canvas.height
  return canvas
###
  loadImage
    - load line imageg widht category and name
  @return Promise<Image,Error>
###
promiseImage = (category, name) ->
  return new Promise (done,fail) ->
    if not category or not name
      return fail new Error("category or name was not given")
    name = path.parse(name).name
    imgpath = "#{category}/#{name}"
    imgurl = "#{process.env.CoherentLinesPath || './cohlines'}/#{imgpath}.jpg"
    img = new Image
    img.onload = -> done(img)
    img.onerror = fail
    img.src = imgurl
module.exports =
  promiseImage: promiseImage
  sliceImage: sliceImage
