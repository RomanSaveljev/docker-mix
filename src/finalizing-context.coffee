Context = require('./context')
Pack = require('./pack')

class FinalizingContext extends Context
  constructor: (pack, prefix) -> super(pack, prefix)
  finalize: -> @pack.finalize()
  pipe: (stream) -> @pack.pipe(stream)

module.exports = FinalizingContext
