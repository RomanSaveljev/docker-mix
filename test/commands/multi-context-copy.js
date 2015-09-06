var MultiContextCopy = require('../../lib/commands/multi-context-copy');
var should = require('should');
var Pack = require('../../lib/pack');
var Context = require('../../lib/context');
var ContextCopy = require('../../lib/commands/context-copy');

describe('MultiContextCopy', function() {
  var contextCopy = new ContextCopy(function() {});
  describe('constructor', function() {
    it('throws without parameters', function() {
      should(function() {new MultiContextCopy()}).throw();
    });
    it('expects all arguments ContextCopy or MultiContextCopy', function() {
      should(function() {new MultiContextCopy(7)}).throw();
      should(function() {new MultiContextCopy(contextCopy)}).not.throw();
      should(function() {new MultiContextCopy(new MultiContextCopy(contextCopy))}).not.throw();
    });
  });
  it('does not override', function() {
    var multi = new MultiContextCopy(contextCopy);
    should(multi.overrides()).be.false();
  });
  describe('applyTo()', function() {
    var pack, context;
    beforeEach(function() {
      pack = new Pack();
      context = new Context(pack);
    });
    it('calls callback', function() {
      var executed = false;
      var copy = new ContextCopy(function() {executed = true});
      var executed2 = false;
      var copy2 = new ContextCopy(function() {executed2 = true});
      var multi = new MultiContextCopy(copy, copy2);
      multi.applyTo(context, []);
      should(executed).be.true();
      should(executed2).be.true();
    });
    it('passes sub-context', function() {
      var dockerfile = [];
      var copy = new ContextCopy(function(context) {
        context.entry({name: '/a.txt'}, '!!!');
      });
      var multi = new MultiContextCopy(copy);
      multi.applyTo(context, dockerfile);
      should(dockerfile[0]).be.equal('COPY sub-1/ /');
      should(context.exists('/sub-1/a.txt')).be.true();
    });
    it('uses unique sub-context', function() {
      pack.entry({name: 'sub-1/a.txt'}, '!');
      var dockerfile = [];
      var copy = new ContextCopy(function(context) {
        context.entry({name: '/a.txt'}, '!!!');
      });
      var multi = new MultiContextCopy(copy);
      multi.applyTo(context, dockerfile);
      should(dockerfile[0]).be.equal('COPY sub-2/ /');
      should(context.exists('/sub-2/a.txt')).be.true();
    });
  });
});
