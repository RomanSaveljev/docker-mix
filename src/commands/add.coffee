Copy = require('./copy')

class Add extends Copy
  constructor: (src, dst) ->
    super(src, dst)
  keyword: -> "ADD"

module.exports = Add
