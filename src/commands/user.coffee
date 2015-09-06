class User
  constructor: (@user) ->
    throw new Error('User is mandatory') unless @user?
  overrides: -> true
  applyTo: (context, dockerfile) ->
    dockerfile.push("USER #{@user}")

module.exports = User
