var Run = require('../../lib/commands/run');
var should = require('should');

describe('Run', function() {
  it('has RUN keyword', function() {
    var run = new Run('echo 123');
    should(run.keyword()).be.equal('RUN');
  });
  it('does not combine exec form', function() {
    var run = new Run('uname', '-a');
    should(run.combines()).be.false();
  });
  it('combines shell form', function() {
    var run = new Run('uname -a');
    should(run.combines()).be.true();
  });
  it('does not override', function() {
    var run = new Run('id');
    should(run.overrides()).be.false();
  });
  it('supports shell form', function() {
    var run = new Run('id -u');
    should(run.toString()).be.equal('RUN id -u');
  });
  it('supports exec form', function() {
    var run = new Run('id', '-u');
    should(run.toString()).be.equal('RUN ["id","-u"]');
  });
});
