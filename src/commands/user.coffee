NullAggregator = require './null-aggregator'

class User
  @aggregator: () -> new NullAggregator()
  constructor: (@user) ->
    throw new Error('User is mandatory') unless @user?
  overrides: -> false
  applyTo: (context, dockerfile) ->
    dockerfile.push("USER #{@user}")

module.exports = User
