ContextCopy = require('./context-copy')
sprintf = require('sprintf')

subFolder = (counter) -> "sub-#{counter}"
subPath = (counter) -> "/#{subFolder(counter)}"

class MultiContextCopy
  constructor: (contextCopy...) ->
    throw new Error('Arguments are mandatory') if contextCopy.length == 0
    @contextCopy = []
    for cc in contextCopy
      if cc instanceof ContextCopy
        @contextCopy.push(cc)
      else if cc instanceof MultiContextCopy
        @contextCopy = @contextCopy.concat(cc.contextCopy)
      else
        throw new Error('All arguments must be ContextCopy or MultiContextCopy')
  keyword: -> 'COPY'
  combines: -> true
  overrides: -> false
  applyTo: (context, dockerfile) ->
    counter = 1
    counter += 1 while context.exists(subPath(counter))
    subContext = context.subContext(subPath(counter))
    cc.applyTo(subContext) for cc in @contextCopy
    dockerfile.push("COPY #{subFolder(counter)}/ /")

module.exports = MultiContextCopy
