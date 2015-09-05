extend = require('extend')

class Cmd
  constructor: (cmd, args...) ->
    if args.length > 0
      # exec form
      @cmd = [cmd]
      @cmd = @cmd.concat(args)
    else
      # shell form
      @cmd = cmd
  toString: ->
    if typeof @cmd == 'string'
      "#{@keyword()} #{@cmd}"
    else
      "#{@keyword()} #{JSON.stringify(@cmd)}"
  keyword: -> "CMD"
  combines: (command) -> false
  overrides: (command) -> true

module.exports = Cmd
