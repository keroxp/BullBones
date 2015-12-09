asesrt= require "assert"
request = require "supertest"
describe "GET /image_match", ->
  it "should return png iamge", (done) ->
    require("../../app") (app) ->
      request(app)
      .get("/image_match")
      .query(line_id: 100)
      .expect(200)
      .expect("Content-Type", "image/png")
      .end(done)
