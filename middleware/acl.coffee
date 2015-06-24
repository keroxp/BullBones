module.exports = (req,res,next) ->
  # アクセス制限
  ip = req.connection.remoteAddress || req.socket.remoteAddress
  host = req.headers.host
  if not host or host is null
    # hostがない場合はブロック
    res.status(400)
  else if ip.match(/127\.0\.0\.1/) or host.match /^localhost/
    # localhsotへのアクセスもしくは自身のIPからのアクセスの場合のみ許す
    next()
  else
    res.status(403)