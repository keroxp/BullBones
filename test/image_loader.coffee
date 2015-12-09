loader = require "../utils/image_loader"
should = require "should"
assert = require "assert"
describe "ImageLoader", ->
  describe "#promiseImage", ->
    it "should load Image", (done) ->
      loader.promiseImage "res/test/anime/lines.png"
      .then (img) ->
        should(img).ok
        done()
    it "should raise error if an error occured", (done) ->
      loader.promiseImage "res/test/hgoe/hgoe.png"
      .catch (e) ->
        should(e).ok
        done()
  describe "#sliceImage", ->
    it "shuold slice image", (done) ->
      loader.promiseImage "res/test/anime/lines.png"
      .then (img) ->
        sliced = loader.sliceImage img, 0, 0, 10, 10
        assert.ok(sliced)
        assert.equal sliced.width, 10
        assert.equal sliced.height, 10
        done()
      .catch done
    it "should raise error if given bounds is invalid", (done) ->
      loader.promiseImage "res/test/anime/lines.png"
      .then (img) ->
        try
          loader.sliceImage img, 0, -1, 10000, 1000
          assert.ok(false)
        catch e
          assert.ok(e)
          done()
      .catch done
