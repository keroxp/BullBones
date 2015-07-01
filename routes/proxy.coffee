request = require "request"

module.exports = () ->
  return (req,res) ->
    url = req.query.url
    unless url
      res.status(400).end()
    else
      try
        x = request(url)
        onerror = (e) ->
          console.log "error for url: #{url}"
          res.status(500).end()
        req.pipe(x).on("error", onerror)
        x.pipe(res)
      catch e
        res.status(400).send(e.toString()).end()