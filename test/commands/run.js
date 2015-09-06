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
});
