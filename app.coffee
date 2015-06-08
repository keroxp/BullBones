express = require 'express'
path = require "path"
http = require "http"
xhr2proxy = require "xhr2proxy"
bodyParser = require 'body-parser'
request = require "request"

app = express()
app.use express.static('public')
app.use bodyParser.urlencoded(extended: true)
app.use bodyParser.json()
app.use xhr2proxy()
app.listen process.env.PORT || 8000
