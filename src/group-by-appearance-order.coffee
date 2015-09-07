extend = require('extend')

module.exports = (array) ->
  sorted = extend([], array)
  for current, i in sorted
    for lookAhead, j in sorted[(i + 1)..]
      if current.constructor == lookAhead.constructor
        if j > 0
          circulate = sorted[(i + 1)..(i + 1 + j)]
          circulate.unshift(circulate.pop())
          sorted[(i + 1)..(i + 1 + j)] = circulate
        break
  return sorted
