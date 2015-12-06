class Rect
  constructor: (@x,@y,@width = 0,@height = 0) ->
  clone: -> new Rect(@x,@y,@width,@height)
  right: -> @x+@width
  bottom: -> @y+@height
  extend: (x,y,w = 0, h = 0) ->
    if x < @x
      @width += @x-x
      @x = x
    else if @right() < x+w
      @width += x+w-@right()
    if y < @y
      @height += @y-y
      @y = y
    else if @bottom() < y+h
      @height += y+h-@bottom()
    this
class Point
  constructor: (@x,@y) ->
  clone: () -> new Point(@x,@y)
module.exports =
  Rect: Rect
  Point: Point
