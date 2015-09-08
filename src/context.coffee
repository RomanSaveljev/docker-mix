path = require('path')
clone = require('clone')
username = require('username')
userid = require('userid')

translatePath = (p, prefix) -> path.relative('/', path.join(prefix, p))

class Context
  constructor: (@pack, @prefix = '/') ->
    throw new Error('Pack is mandatory parameter') unless @pack?
    throw new Error('prefix must be an absolute path') unless path.isAbsolute(@prefix)
    user = username.sync()
    @uid = userid.uid(user)
    @gid = userid.gid(user)
    @uname = userid.username(@uid)
    @gname = userid.groupname(@gid)
  entry: (opts, contents) ->
    throw new Error('opts.name is mandatory') unless opts.name?
    throw new Error('Only absolute paths are supported for opts.name') unless path.isAbsolute(opts.name)
    opts = clone(opts)
    opts.name = translatePath(opts.name, @prefix)
    unless opts.uid?
      opts.uid = @uid
      opts.uname = @uname
    unless opts.gid?
      opts.gid = @gid
      opts.gname = @gname
    @pack.entry(opts, contents)
  subContext: (prefix) ->
    throw new Error('prefix must be an absolute path') unless path.isAbsolute(prefix)
    new Context(@pack, path.join(@prefix, prefix))
  exists: (p) ->
    throw new Error('argument must be absolute path') unless path.isAbsolute(p)
    @pack.exists(translatePath(p, @prefix))
  all: -> (path.join('/', p) for p in @pack.all(path.relative('/', @prefix)))

module.exports = Context
