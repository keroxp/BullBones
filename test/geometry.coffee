assert = require "assert"
{Rect} = require "../utils/geometry"

describe "geometry", ->
  describe "Rect", ->
    describe "#new", ->
      it "should be initialized correctly", ->
        r = new Rect(1,2,3,4)
        assert.equal r.x, 1
        assert.equal r.y, 2
        assert.equal r.width, 3
        assert.equal r.height, 4
    describe "#extend", ->
      it "should be extended to back correctly", ->
        r = new Rect(0,0)
        r.extend -10, -10
        assert.equal r.x, -10
        assert.equal r.y, -10
        assert.equal r.width, 10
        assert.equal r.height, 10
      it "shuold be extended to foward correctly", ->
        r = new Rect(10,10)
        r.extend 20, 30
        assert.equal r.x, 10
        assert.equal r.y, 10
        assert.equal r.width, 10
        assert.equal r.height, 20
