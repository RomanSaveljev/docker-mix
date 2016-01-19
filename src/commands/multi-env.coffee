class Aggregator
  constructor: () ->
    @multiEnv = 'MULTI_ENV_AGGREGATE'
  aggregator: () -> @
  equals: (what) -> what.multiEnv? and what.multiEnv is @multiEnv
  aggregate: (args...) -> new MultiEnv(args...)

class MultiEnv
  @aggregator: () -> new Aggregator()
  constructor: (env...) ->
    throw new Error('Env is mandatory') unless env.length > 0
    @env = []
    for e in env
      if e.env instanceof Array
        @env = @env.concat(e.env)
      else if e.name? and e.value?
        @env.push(e)
      else
        throw new Error('Does not have name or value property')
  applyTo: (context, dockerfile) ->
    if @env.length == 1
      dockerfile.push("ENV \"#{@env[0].name}\" #{@env[0].value}")
    else if @env.length > 1
      dockerfile.push('ENV ' + ("\"#{e.name}\"=\"#{e.value}\"" for e in @env).join(' '))

module.exports = MultiEnv
