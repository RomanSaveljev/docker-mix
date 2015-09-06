tar = require('tar-stream')
path = require('path')

class Pack
  constructor: ->
    @pack = tar.pack()
    @paths = {}
  entry: (opts, content) ->
    iteration = (p, paths) ->
      if p == '.'
        return paths
      else
        paths = iteration(path.dirname(p), paths)
        paths[path.basename(p)] ?= {}
        return paths[path.basename(p)]
    iteration(opts.name, @paths)
    return @pack.entry(opts, content)
  finalize: -> @pack.finalize()
  exists: (p) ->
    iteration = (p, paths) ->
      if p == '.'
        return paths
      else
        paths = iteration(path.dirname(p), paths)
        return paths unless paths?
        return paths[path.basename(p)]
    return iteration(p, @paths)?

module.exports = Pack
