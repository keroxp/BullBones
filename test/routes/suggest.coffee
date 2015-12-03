assert = require "assert"
Canvas = require "canvas"
Image = Canvas.Image
request = require "supertest"
require "should"
route = require "../../app"

describe "POST /suggest", ->
  app = null
  before (done) ->
    route (_app) ->
       app = _app
       done()
  it "should be return 400 if dataURL was not gived", (done) ->
    request(app)
    .post("/suggest")
    .type("form")
    .send(hoge: "hoge")
    .expect(400,done)
  it "should be return 400 if dataURL was invalid", (done) ->
    request(app)
    .post("/suggest")
    .type("form")
    .send(dataURL: "hogehoge")
    .expect(400,done)
  it "should be return similar lines if query line image was given", (done) ->
    canvas = new Canvas
    testimg = new Image
    testimg.onload = ->
      canvas.width = testimg.width
      canvas.height = testimg.height
      ctx = canvas.getContext("2d")
      ctx.drawImage(testimg,0,0)
      url = canvas.toDataURL()
      request(app)
      .post("/suggest")      
      .send(dataURL: url)
      .expect(200)
      .expect("Content-Type","image/png")
      .end(done)
    testimg.src = "tmp/test.png"
