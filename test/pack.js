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
    })
  });
});
