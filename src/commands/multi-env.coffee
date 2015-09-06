Env = require('./env')

class MultiEnv
  constructor: (env...) ->
    throw new Error('Env is mandatory') unless env.length > 0
    @env = []
    for e in env
      if e instanceof Env
        @env.push(e)
      else if e instanceof MultiEnv
        @env = @env.concat(e.env)
      else
        throw new Error('All arguments must be Env or MultiEnv')
  applyTo: (context, dockerfile) ->
    if @env.length == 1
      dockerfile.push("ENV \"#{@env[0].name}\" #{@env[0].value}")
    else if @env.length > 1
      dockerfile.push('ENV ' + ("\"#{e.name}\"=\"#{e.value}\"" for e in @env).join(' '))

module.exports = MultiEnv
