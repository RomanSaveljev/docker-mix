class Run
  constructor: (@run) ->
    throw new Error("Argument is mandatory") unless @run?
  overrides: (command) -> false

module.exports = Run
