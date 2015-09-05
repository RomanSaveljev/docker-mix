var Volume = require('../../lib/commands/volume');
var should = require('should');

describe('Volume', function() {
  it('has VOLUME keyword', function() {
    var volume = new Volume('/a');
    should(volume.keyword()).be.equal('VOLUME');
  });
  it('constructor throws without parameters', function() {
    should(function() {new Volume()}).throw();
  });
  it('combines', function() {
    var volume = new Volume('/a/b');
    should(volume.combines()).be.true();
  });
  it('does not override', function() {
    var volume = new Volume('/a/b');
    should(volume.overrides()).be.false();
  });
  it('uses volume value', function() {
    var volume = new Volume('/c');
    should(volume.toString()).be.equal('VOLUME /c');
  });
});
