class User
  constructor: (@user) ->
    throw new Error('User is mandatory') unless @user?
  keyword: -> 'USER'
  combines: -> false
  overrides: -> true
  toString: -> "#{@keyword()} #{@user}"

module.exports = User
