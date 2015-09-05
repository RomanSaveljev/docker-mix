class Run
  constructor: (run, args...) ->
    if args.length > 0
      # exec form
      @run = [run]
      @run = @run.concat(args)
    else
      # shell form
      @run = run
  toString: ->
    if typeof @run == 'string'
      "#{@keyword()} #{@run}"
    else
      "#{@keyword()} #{JSON.stringify(@run)}"
  keyword: -> "RUN"
  combines: (command) -> typeof @run == 'string'
  overrides: (command) -> false

module.exports = Run
