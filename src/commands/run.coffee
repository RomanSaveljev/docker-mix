class Run
  constructor: (@run, args...) ->
    throw new Error("Argument is mandatory") unless @run?
    if args.length > 0
      # exec form
      @run = [@run] unless typeof @run == 'array'
      @run = @run.concat(args)
    # no else - shell form stays as it is
    # no else - user can pass an array and it shall become an exec form as well
  overrides: (command) -> false
  execForm: -> Array.isArray(@run)

module.exports = Run
