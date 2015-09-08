tar = require('tar-stream')
path = require('path')

findSubtree = (p, paths) ->
  if p == '.'
    return paths
  else
    paths = findSubtree(path.dirname(p), paths)
    return paths unless paths?
    return paths[path.basename(p)]

createSubtree = (p, paths) ->
  if p == '.'
    return paths
  else
    paths = createSubtree(path.dirname(p), paths)
    paths[path.basename(p)] ?= {}
    return paths[path.basename(p)]

class Pack
  constructor: ->
    @pack = tar.pack()
    @paths = {}
  entry: (opts, content) ->
    createSubtree(opts.name, @paths)
    return @pack.entry(opts, content)
  finalize: -> @pack.finalize()
  exists: (p) ->
    findSubtree(p, @paths)?
  pipe: (stream) -> @pack.pipe(stream)
  all: (prefix = '') ->
    prefix = '.' if prefix == ''
    results = []
    subTree = findSubtree(prefix, @paths)
    #console.dir(subTree)
    if subTree?
      walk = (collector, tree) ->
        keys = (t for t of tree)
        if keys.length == 0
          results.push(collector)
        else
          for t in keys
            subPath = path.join(collector, t)
            #results.push(subPath)
            walk(subPath, tree[t])
      walk('.', subTree)
    return results

module.exports = Pack
