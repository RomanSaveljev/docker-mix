var Entrypoint = require('../../lib/commands/entrypoint');
var should = require('should');

describe('Entrypoint', function() {
  it('overrides', function() {
    var entrypoint = new Entrypoint('id');
    should(entrypoint.overrides()).be.true();
  });
  describe('applyTo()', function() {
    dockerfile = [];
    it('supports shell form', function() {
      var entrypoint = new Entrypoint('id -u');
      entrypoint.applyTo({}, dockerfile);
      should(dockerfile.pop()).be.equal('ENTRYPOINT id -u');
    });
    it('supports exec form', function() {
      var entrypoint = new Entrypoint('id', '-u');
      entrypoint.applyTo({}, dockerfile);
      should(dockerfile.pop()).be.equal('ENTRYPOINT ["id","-u"]');
    });
  });
});
