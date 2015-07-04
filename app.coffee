newrelic = require "newrelic"
express = require 'express'
session = require 'express-session'
path = require "path"
http = require "http"
bodyParser = require 'body-parser'
request = require "request"
debug = require("debug")("app")
acl = require "./middleware/acl"
{ MongoClient } = require "mongodb"
MongoStore = require("connect-mongo")(session)

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
  app.use session {
      secret: process.env.SESSION_SECRET || "bullbones_secred"
      name: "bullbones.connect.sid"
      resave: false
      saveUninitialized: true
      store: new MongoStore({
          url: mongo_url
          ttl: 7 * 24 * 60 * 60 # =7 days
        })
      cookie:
        maxAge: 7 * 24 * 60 * 60
    }
  app.get '/', (req,res) ->
    req.session.isValid = true
    res.render "index", app_env: app_env
  app.get '/about', (req,res) -> res.render "about"
  app.get '/proxy', acl require("./routes/proxy")()
  app.get '/search', acl require("./routes/search")(db)
  app.post '/export', acl require("./routes/export")(db)
  app.get '/export/signed_url', acl require("./routes/signed_url")()
  app.get '/test', (req,res) -> res.send("sessionId: #{req.sessionID}, session: #{req.session.toString()}")
  app.get '/images/:id:ext(.jpg|.png)?', require("./routes/images")(db)
  app.listen process.env.PORT || 8000
