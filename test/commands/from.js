var From = require('../../lib/commands/from');
var should = require('should');

describe('From', function() {
  it('has FROM keyword', function() {
    var from = new From('image');
    should(from.keyword()).be.equal('FROM');
  });
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
  it('uses all parameters in toString()', function() {
    var opts = {
      registry: 'some.hub.com',
      user: 'munamies',
      image: 'cool-image',
      tag: '4.0.12'
    };
    var from = new From(opts);
    should(from.toString()).be.equal('FROM some.hub.com/munamies/cool-image:4.0.12');
  });
  it('skips undefined registry name', function() {
    var opts = {
      user: 'munamies',
      image: 'cool-image',
      tag: '4.0.12'
    };
    var from = new From(opts);
    should(from.toString()).be.equal('FROM munamies/cool-image:4.0.12');
  });
  it('skips undefined user name', function() {
    var opts = {
      image: 'cool-image',
      tag: '4.0.12'
    };
    var from = new From(opts);
    should(from.toString()).be.equal('FROM cool-image:4.0.12');
  });
  it('uses default tag', function() {
    var opts = {
      image: 'cool-image'
    };
    var from = new From(opts);
    should(from.toString()).be.equal('FROM cool-image:latest');
  });
  it('does not combine', function() {
    var from = new From('image');
    should(from.combines()).be.false();
  });
  it('overrides', function() {
    var from = new From('image');
    should(from.overrides()).be.true();
  });
  it('throws it image name is skipped', function() {
    should(function() {new From({})}).throw();
  });
  it('uses first string parameter as image name', function() {
    var from = new From('zoink');
    should(from.image).be.equal('zoink');
  });
  it('throws if no parameters passed', function() {
    should(function() {new From()}).throw();
  });
});
