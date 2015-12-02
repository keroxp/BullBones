request = require "supertest"
describe "GET /coherent_lines", ->
  app = null
  before (done) ->
    require("../../app") (res) ->
      app = res
      done()
  it "should be return 400 if parameters were given incompletely", (done)->
    request(app)
      .get("/coherent_lines")
      .query(sx: 10, sy: 20)
      .expect(400)
      .end(done)
  it "should be return 404 if image with category and name was not found", (done)->
    request(app)
      .get("/coherent_lines")
      .query(category: "nothing", name: "unknown")
      .query(sx: 10, sy: 10, width: 100, height: 200)
      .expect(404)
      .end(done)
  it "should be return 400 if given bounds of sx, sy, width, height doesn't match source image", (done)->
    request(app)
      .get("/coherent_lines")
      .query(category: "test", name: "anime")
      .query(sx:10000,sy:0, width: 10000, height: 200000)
      .expect(400)
      .end(done)
  it "shoule be png image", (done)->
    request(app)
      .get("/coherent_lines")
      .query(category: "test", name: "anime")
      .query(sx: 0, sy: 0, width: 26, height: 48)
      .expect(200)
      .expect("Content-Type", "image/png")
      .end(done)
