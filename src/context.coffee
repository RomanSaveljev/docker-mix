path = require('path')
clone = require('clone')

translatePath = (p, prefix) -> path.relative('/', path.join(prefix, p))

class Context
  constructor: (@pack, @prefix = '/') ->
    throw new Error('Pack is mandatory parameter') unless @pack?
    throw new Error('prefix must be an absolute path') unless path.isAbsolute(@prefix)
  entry: (opts, contents) ->
    throw new Error('opts.name is mandatory') unless opts.name?
    throw new Error('Only absolute paths are supported for opts.name') unless path.isAbsolute(opts.name)
    opts = clone(opts)
    opts.name = translatePath(opts.name, @prefix)
    @pack.entry(opts, contents)
  subContext: (prefix) ->
    throw new Error('prefix must be an absolute path') unless path.isAbsolute(prefix)
    new Context(@pack, path.join(@prefix, prefix))
  exists: (p) ->
    throw new Error('argument must be absolute path') unless path.isAbsolute(p)
    @pack.exists(translatePath(p, @prefix))

module.exports = Context
