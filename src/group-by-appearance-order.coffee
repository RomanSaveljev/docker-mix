extend = require('extend')

module.exports = (array) ->
  sorted = extend([], array)
  for current, i in sorted
    aggregator = current.constructor.aggregator()
    for lookAhead, j in sorted[(i + 1)..]
      if aggregator.equals(lookAhead.constructor.aggregator())
        if j > 0
          circulate = sorted[(i + 1)..(i + 1 + j)]
          circulate.unshift(circulate.pop())
          sorted[(i + 1)..(i + 1 + j)] = circulate
        break
  return sorted
