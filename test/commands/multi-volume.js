var MultiVolume = require('../../lib/commands/multi-volume');
var should = require('should');
var Volume = require('../../lib/commands/volume');

describe('MultiVolume', function() {
  var dockerfile = [];
  var volume = new Volume('/a');
  it('constructor throws without parameters', function() {
    should(function() {new MultiVolume()}).throw();
  });
  it('constructor expects parameters to be Volume or MultiVolume', function() {
    should(function() {new MultiVolume('abc')}).throw();
    should(function() {new MultiVolume(volume)}).not.throw();
    should(function() {new MultiVolume(new MultiVolume(volume))}).not.throw();
  });
  it('formats all volumes included', function() {
    var volume2 = new Volume('/c');
    var volume3 = new Volume('/e');
    var multiVolume = new MultiVolume(volume2, volume3);
    var multiVolume2 = new MultiVolume(multiVolume, volume);
    multiVolume2.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('VOLUME ["/c","/e","/a"]');
  });
  it('formats one volume in a special way', function() {
    var multiVolume = new MultiVolume(volume);
    multiVolume.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('VOLUME /a');
  });
});
