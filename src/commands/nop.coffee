class Nop
  applyTo: (context, dockerfile) ->
    dockerfile.push("# NOP")
  overrides: (command) -> false

module.exports = Nop
