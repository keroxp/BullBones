request = require "request"

module.exports = () ->
  return (req,res) ->
    url = req.query.url
    x = request(url)
    onerror = (e) ->
      console.log "error for url: #{url}"
      res.writeHead(500)
      res.end()
    req.pipe(x).on("error", onerror)
    x.pipe(res)

