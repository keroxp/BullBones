express = require 'express'
path = require "path"
http = require "http"
bodyParser = require 'body-parser'
request = require "request"

app = express()
app.use express.static('public')
app.use bodyParser.urlencoded(extended: true)
app.use bodyParser.json()
app.get '/proxy', (req, res) ->
  # url?=http://example.com/hoge.png# url?=http://example.com/hoge.png
  url = req.query.url
  x = request(url)
  onerror = (e) ->
    console.log "error for url: #{url}"
    res.writeHead(500)
    res.end()
  req.pipe(x).on("error", onerror)
  x.pipe(res)
app.listen process.env.PORT || 8000
