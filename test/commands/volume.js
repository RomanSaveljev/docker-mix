var Volume = require('../../lib/commands/volume');
var should = require('should');

describe('Volume', function() {
  it('constructor throws without parameters', function() {
    should(function() {new Volume()}).throw();
  });
  it('does not override', function() {
    var volume = new Volume('/a/b');
    should(volume.overrides()).be.false();
  });
});
