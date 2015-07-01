module.exports = (route) ->
  return ((_route) ->
    return (req,res,next) ->
      host = req.headers.host
      if (host and host.match /^localhost/) or req.session.isValid
        _route(req,res,next)
      else
        return res.status(403).send("session is invalid.").end() if !req.session.isValid
        return res.status(403).end("host was not given.") if !req.headers.host
        return res.status(403).end("not development environement.") if !req.headers.host.match /^localhost/
  )(route)