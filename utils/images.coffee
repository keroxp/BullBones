Canvas = require "canvas"
Image = Canvas.Image
ImageData = Canvas.ImageData
canvas = new Canvas

module.exports =
  map: (image,callback) ->
    canvas.width = image.width
    canvas.height = image.height
    ctx = canvas.getContext "2d"
    ctx.drawImage image, 0, 0
    {data} = ctx.getImageData(0,0,canvas.width,canvas.height)
    buf = new ImageData(image.width,image.height)
    for y in [0..canvas.height-1]
      for x in [0..canvas.width-1]
        i = (y*canvas.width+x)*4
        m = callback
          x: x
          y: y
          r: data[i]
          g: data[i+1]
          b: data[i+2]
          a: data[i+3]
        buf.data[i] = m.r
        buf.data[i+1] = m.g
        buf.data[i+2] = m.b
        buf.data[i+3] = m.a
    ctx.putImageData buf, 0, 0
    img = new Image
    img.src = canvas.toBuffer()
    return img
