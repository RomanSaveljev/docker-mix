var Cmd = require('../../lib/commands/cmd');
var should = require('should');

describe('Cmd', function() {
  it('overrides', function() {
    var cmd = new Cmd('id');
    should(cmd.overrides()).be.true();
  });
  describe('applyTo()', function() {
    dockerfile = [];
    it('supports shell form', function() {
      var cmd = new Cmd('id -u');
      cmd.applyTo({}, dockerfile);
      should(dockerfile.pop()).be.equal('CMD id -u');
    });
    it('supports exec form', function() {
      var cmd = new Cmd('id', '-u');
      cmd.applyTo({}, dockerfile);
      should(dockerfile.pop()).be.equal('CMD ["id","-u"]');
    });
  });
});
