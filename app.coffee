newrelic = require "newrelic"
express = require 'express'
path = require "path"
http = require "http"
bodyParser = require 'body-parser'
request = require "request"
{ MongoClient } = require "mongodb"
mongo_url = process.env.MONGOLAB_URI || "mongodb://localhost:27017/bullbones"
app_env = process.env.APP_ENV || "development"
MongoClient.connect mongo_url, (err,db) ->
  console.log err if err
  app = express()
  app.set "views", path.resolve("./views")
  app.set "view engine", "jade"
  app.use express.static('public')
  app.use bodyParser.urlencoded(extended: true)
  app.use bodyParser.json()
  # app.use require("./middleware/acl")
  app.get '/', (req,res) -> res.render "index", app_env: app_env
  app.get '/proxy', require("./routes/proxy")()
  app.get '/search', require("./routes/search")(db)
  app.listen process.env.PORT || 8000
