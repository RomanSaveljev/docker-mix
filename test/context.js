var Context = require('../lib/context');
var should = require('should');
var Pack = require('../lib/pack');

describe('Context', function() {
  describe('constructor', function() {
    it('throws without parameters', function() {
      should(function() {new Context()}).throw();
    });
  });
  describe('entry()', function() {
    it('throws with relative path', function() {
      var context = new Context(new Pack());
      should(function() {context.entry({name: 'a/b.txt'}, '!!')}).throw();
    });
    it('adds entry to pack', function() {
      var pack = new Pack();
      var context = new Context(pack);
      context.entry({name: '/a/b/c.txt'}, 'CCC');
      should(pack.exists('a/b/c.txt')).be.true();
    });
    it('respects prefix', function() {
      var pack = new Pack();
      var context = new Context(pack, '/a');
      context.entry({name: '/b/c.txt'}, 'CCC');
      should(pack.exists('a/b/c.txt')).be.true();
      should(pack.exists('b/c.txt')).be.false();
    });
  });
  describe('exists()', function() {
    it('returns what Pack#exists() returns', function() {
      var pack = new Pack();
      pack.entry({name: 'a/b/c.txt'}, '123');
      var context = new Context(pack);
      should(context.exists('/a/b/c.txt')).be.true();
    });
    it('respects prefix', function() {
      var pack = new Pack();
      pack.entry({name: 'a/b/c.txt'}, '123');
      var context = new Context(pack, '/a');
      should(context.exists('/b/c.txt')).be.true();
      should(context.exists('/a/b/c.txt')).be.false();
    });
  });
  describe('subContext()', function() {
    it('assigns prefix', function() {
      var pack = new Pack();
      pack.entry({name: 'a/b/c.txt'}, '123');
      var context = new Context(pack);
      var sub = context.subContext('/a');
      should(sub.exists('/b/c.txt')).be.true();
    });
  });
  describe('all()', function() {
    var pack = new Pack();
    pack.entry({name: 'a/b/c.txt'}, '123');
    pack.entry({name: 'd/e/f.txt'}, '123');
    it('lists asbolute paths', function() {
      var context = new Context(pack);
      var results = context.all();
      should(results).have.length(2);
      should(results).containEql('/a/b/c.txt');
      should(results).containEql('/d/e/f.txt');
    });
    it('lists under prefix', function() {
      var context = new Context(pack, '/a/b');
      var results = context.all();
      should(results).have.length(1);
      should(results).containEql('/c.txt');
    })
  });
});
