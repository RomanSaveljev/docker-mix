Cmd = require('./cmd')

class Entrypoint extends Cmd
  constructor: (args...) ->
    # super(args) will use call, i.e. args will passed as array
    Entrypoint.__super__.constructor.apply(this, args)
  keyword: -> 'ENTRYPOINT'

module.exports = Entrypoint
