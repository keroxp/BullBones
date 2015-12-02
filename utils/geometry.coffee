class Rect
  constructor: (@x,@y,@width = 0,@height = 0) ->
  clone: -> new Rect(@x,@y,@width,@height)
  extend: (x,y,w = 0, h = 0) ->
    if @x < x
      @x = x
      @width += @x-x
    else if @x+@width < x+w
      @width += x+w-(@x+width)
    if @y < y
      @y = y
      @height += @y-y
    else if @y+@height < y+h
      @height += y+h-(@y+@height)
    this
class Point
  constructor: (@x,@y) ->
  clone: () -> new Point(@x,@y)
module.exports =
  Rect: Rect
  Point: Point
