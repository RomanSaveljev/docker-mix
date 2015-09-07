var Run = require('../../lib/commands/run');
var should = require('should');

describe('Run', function() {
  var dockerfile = [];
  it('does not override', function() {
    var run = new Run('id');
    should(run.overrides()).be.false();
  });
  it('constructor throws without parameters', function() {
    should(function() {new Run()}).throw();
  });
  it('creates exec form from multiple arguments', function() {
    var run = new Run('wc', '-l');
    should(run.execForm()).be.true();
  });
  it('creates exec form a single array argument', function() {
    var run = new Run(['wc', '-l']);
    should(run.execForm()).be.true();
  });
  it('creates shell form from a single argument', function() {
    var run = new Run('uname');
    should(run.execForm()).be.false();
  });
  it('creates exec from from a one element argument', function() {
    var run = new Run(['true']);
    should(run.execForm()).be.true();
  });
});
