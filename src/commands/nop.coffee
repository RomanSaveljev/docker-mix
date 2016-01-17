NullAggregator = require './null-aggregator'

class Nop
  @aggregator: () -> new NullAggregator()
  applyTo: (context, dockerfile) ->
    dockerfile.push("# NOP")
  overrides: (command) -> false

module.exports = Nop
