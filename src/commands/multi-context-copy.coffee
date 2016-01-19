sprintf = require('sprintf')

class Aggregator
  constructor: () ->
    @multiContextCopy = 'MULTI_CONTEXT_AGGREGATE'
  aggregator: () -> @
  equals: (what) -> what.multiContextCopy? and what.multiContextCopy is @multiContextCopy
  aggregate: (args...) -> new MultiContextCopy(args...)

subFolder = (counter) -> sprintf("%03d", counter)
subPath = (counter) -> "/#{subFolder(counter)}"

class MultiContextCopy
  @aggregator: () -> new Aggregator()
  constructor: (contextCopy...) ->
    throw new Error('Arguments are mandatory') if contextCopy.length == 0
    @contextCopy = []
    for cc in contextCopy
      if cc.contextCopy instanceof Array
        @contextCopy = @contextCopy.concat(cc.contextCopy)
      else if typeof cc.applyTo is 'function'
        @contextCopy.push(cc)
      else
        throw new Error("Does not have applyTo method")
  overrides: -> false
  applyTo: (context, dockerfile) ->
    counter = 1
    counter += 1 while context.exists(subPath(counter))
    subContext = context.subContext(subPath(counter))
    cc.applyTo(subContext) for cc in @contextCopy
    dockerfile.push("# #{subFolder(counter)}#{p} -> #{p}") for p in subContext.all()
    dockerfile.push("COPY #{subFolder(counter)}/ /")

module.exports = MultiContextCopy
