var MultiVolume = require('../../lib/commands/multi-volume');
var should = require('should');
var Volume = require('../../lib/commands/volume');

describe('MultiVolume', function() {
  var volume = new Volume('/a');
  it('has VOLUME keyword', function() {
    var multiVolume = new MultiVolume(volume);
    should(multiVolume.keyword()).be.equal('VOLUME');
  });
  it('combines', function() {
    var multiVolume = new MultiVolume(volume);
    should(multiVolume.combines()).be.true();
  });
  it('does not override', function() {
    var multiVolume = new MultiVolume(volume);
    should(multiVolume.overrides()).be.false();
  });
  it('constructor throws without parameters', function() {
    should(function() {new MultiVolume()}).throw();
  });
  it('constructor expects parameters to be Volume or MultiVolume', function() {
    should(function() {new MultiVolume('abc')}).throw();
    should(function() {new MultiVolume(volume)}).not.throw();
    should(function() {new MultiVolume(new MultiVolume(volume))}).not.throw();
  });
  it('renders all volumes included', function() {
    var volume2 = new Volume('/c');
    var volume3 = new Volume('/e');
    var multiVolume = new MultiVolume(volume2, volume3);
    var multiVolume2 = new MultiVolume(multiVolume, volume);
    should(multiVolume2.toString()).be.equal('VOLUME ["/c","/e","/a"]');
  });
});
