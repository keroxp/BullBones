newrelic = require "newrelic"
express = require 'express'
path = require "path"
http = require "http"
async = require "async"
bodyParser = require 'body-parser'
request = require "request"
debug = require("debug")("app")
mysql = require "mysql"
{ MongoClient } = require "mongodb"

mongo_url = process.env.MONGOLAB_URI || "mongodb://localhost:27017/bullbones"
app_env = process.env.APP_ENV || "development"

module.exports = (done) ->
  async.parallel
    mongo: (cb) ->
      MongoClient.connect mongo_url, (err, db) ->
        cb(err, db: db)
    mysql: (cb) ->
      connection = mysql.createConnection
        host: process.env.MySQL_HOST || "localhost"
        user: process.env.MySQL_USER || "root"
        password: process.env.MySQL_PASSWORD || "password"
        database: process.env.MySQL_DB_NAME || "bullghost"
      connection.connect (err) ->
        cb(err, connection: connection)
  , (err, res) ->
    debug err if err
    app = express()
    app.set "views", path.resolve("./views")
    app.set "view engine", "jade"
    app.use express.static('public')
    app.use bodyParser.urlencoded(extended: true)
    app.use bodyParser.json()
    app.get '/', (req,res) -> res.render "index", app_env: app_env
    app.get '/about', (req,res) -> res.render "about"
    app.get '/proxy', require("./routes/proxy")()
    app.get '/search', require("./routes/search")(res.mongo.db)
    app.post '/suggest', require("./routes/suggest")(res.mysql.connection)
    app.get '/coherent_lines', require("./routes/coherent_lines")
    app.post '/export', require("./routes/export")(res.mongo.db)
    app.get '/export/signed_url', require("./routes/signed_url")()
    app.get '/images/:id:ext(.jpg|.png)?', require("./routes/images")(res.mongo.db)
    app.get '/images', require("./routes/images_index")(res.mongo.db)
    app.listen process.env.PORT || 8000
    done(app) if done
