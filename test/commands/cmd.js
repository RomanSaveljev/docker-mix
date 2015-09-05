var Cmd = require('../../lib/commands/cmd');
var should = require('should');

describe('Cmd', function() {
  it('has CMD keyword', function() {
    var cmd = new Cmd('echo 123');
    should(cmd.keyword()).be.equal('CMD');
  });
  it('does not combine', function() {
    var cmd = new Cmd('id');
    should(cmd.combines()).be.false();
  });
  it('overrides', function() {
    var cmd = new Cmd('id');
    should(cmd.overrides()).be.true();
  });
  it('supports shell form', function() {
    var cmd = new Cmd('id -u');
    should(cmd.toString()).be.equal('CMD id -u');
  });
  it('supports exec form', function() {
    var cmd = new Cmd('id', '-u');
    should(cmd.toString()).be.equal('CMD ["id","-u"]');
  });
});
