var Pack = require('../lib/pack');
var should = require('should')

describe('Pack', function() {
  describe('exists()', function() {
    it('detects existence', function() {
      var pack = new Pack();
      pack.entry({name: 'a/b/c/d.txt'}, 'ARGH!!');
      should(pack.exists('a/b/c/d.txt')).be.true();
    });
    it('detects non-existence', function() {
      var pack = new Pack();
      pack.entry({name: 'a/b/c.txt'}, '123');
      should(pack.exists('d/b/c.txt')).be.false();
      should(pack.exists('a/b/d.txt')).be.false();
      should(pack.exists('a/d/c.txt')).be.false();
    });
    it('detects folder existence', function() {
      var pack = new Pack();
      pack.entry({name: 'a/b/c/d/e.txt'}, 'abc');
      should(pack.exists('a')).be.true();
      should(pack.exists('a/b')).be.true();
      should(pack.exists('a/b/c')).be.true();
      should(pack.exists('a/b/c/d')).be.true();
      should(pack.exists('a/b/c/d/')).be.true();
    });
  });
  describe('all()', function() {
    it('lists all without prefix', function() {
      var pack = new Pack();
      pack.entry({name: 'a/b/c.txt'}, 'abc');
      pack.entry({name: 'd/e/f.txt'}, 'abc');
      pack.entry({name: 'a/1.txt'}, 'abc');
      results = pack.all();
      should(results).have.length(3);
      should(results).containEql('a/b/c.txt');
      should(results).containEql('d/e/f.txt');
      should(results).containEql('a/1.txt');
    });
    it('lists under prefix', function() {
      var pack = new Pack();
      pack.entry({name: 'a/b/c/d.txt'}, '123');
      should(pack.all('a')).be.eql(['b/c/d.txt']);
      should(pack.all('a/b')).be.eql(['c/d.txt']);
      should(pack.all('a/b/c')).be.eql(['d.txt']);
    });
    it('empty array for wrong prefix', function() {
      var pack = new Pack();
      pack.entry({name: 'a/b/c/d.txt'}, '123');
      should(pack.all('zzzz/yyy')).be.eql([]);
    });
  });
});
