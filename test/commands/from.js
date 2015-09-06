var From = require('../../lib/commands/from');
var should = require('should');

describe('From', function() {
  var dockerfile = [];
  it('sets default tag to latest', function() {
    var from = new From('image');
    should(from.tag).be.equal('latest');
  });
  it('saves registry name', function() {
    var from = new From({image: 'image', registry: 'registry'});
    should(from.registry).be.equal('registry');
  });
  it('saves user name', function() {
    var from = new From({image: 'image', user: 'user'});
    should(from.user).be.equal('user');
  });
  it('saves image name', function() {
    var from = new From({image: 'image'});
    should(from.image).be.equal('image');
  });
  it('saves tag name', function() {
    var from = new From({image: 'image', tag: 'tag'});
    should(from.tag).be.equal('tag');
  });
  it('uses all parameters in applyTo()', function() {
    var opts = {
      registry: 'some.hub.com',
      user: 'munamies',
      image: 'cool-image',
      tag: '4.0.12'
    };
    var from = new From(opts);
    from.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('FROM some.hub.com/munamies/cool-image:4.0.12');
  });
  it('skips undefined registry name', function() {
    var opts = {
      user: 'munamies',
      image: 'cool-image',
      tag: '4.0.12'
    };
    var from = new From(opts);
    from.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('FROM munamies/cool-image:4.0.12');
  });
  it('skips undefined user name', function() {
    var opts = {
      image: 'cool-image',
      tag: '4.0.12'
    };
    var from = new From(opts);
    from.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('FROM cool-image:4.0.12');
  });
  it('uses default tag', function() {
    var opts = {
      image: 'cool-image'
    };
    var from = new From(opts);
    from.applyTo({}, dockerfile)
    should(dockerfile.pop()).be.equal('FROM cool-image:latest');
  });
  it('overrides', function() {
    var from = new From('image');
    should(from.overrides()).be.true();
  });
  it('throws if image name is skipped', function() {
    should(function() {new From({})}).throw();
  });
  it('uses first string parameter as image name', function() {
    var from = new From('zoink');
    from.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('FROM zoink:latest');
  });
  it('uses second string parameter as tag', function() {
    var from = new From('zoink', '20');
    from.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('FROM zoink:20');    
  });
  it('throws if no parameters passed', function() {
    should(function() {new From()}).throw();
  });
});
