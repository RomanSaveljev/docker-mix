var ExecRun = require('../../lib/commands/exec-run');
var should = require('should');

describe('ExecRun', function() {
  var dockerfile = [];
  it('does not override', function() {
    var execRun = new ExecRun('id');
    should(execRun.overrides()).be.false();
  });
  it('supports exec form', function() {
    var execRun = new ExecRun('id', '-u');
    execRun.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN ["id","-u"]');
  });
});
