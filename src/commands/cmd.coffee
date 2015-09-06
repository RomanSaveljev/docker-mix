class Cmd
  constructor: (cmd, args...) ->
    if args.length > 0
      # exec form
      @cmd = [cmd]
      @cmd = @cmd.concat(args)
    else
      # shell form
      @cmd = cmd
  applyTo: (context, dockerfile) ->
    dockerfile.push('CMD ' + (if typeof @cmd == 'string' then @cmd else JSON.stringify(@cmd)))
  overrides: -> true

module.exports = Cmd
