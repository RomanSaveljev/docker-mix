var Entrypoint = require('../../lib/commands/entrypoint');
var should = require('should');

describe('Entrypoint', function() {
  it('has CMD keyword', function() {
    var entrypoint = new Entrypoint('echo 123');
    should(entrypoint.keyword()).be.equal('ENTRYPOINT');
  });
  it('does not combine', function() {
    var entrypoint = new Entrypoint('id');
    should(entrypoint.combines()).be.false();
  });
  it('overrides', function() {
    var entrypoint = new Entrypoint('id');
    should(entrypoint.overrides()).be.true();
  });
  it('supports shell form', function() {
    var entrypoint = new Entrypoint('id -u');
    should(entrypoint.toString()).be.equal('ENTRYPOINT id -u');
  });
  it('supports exec form', function() {
    var entrypoint = new Entrypoint('id', '-u');
    should(entrypoint.toString()).be.equal('ENTRYPOINT ["id","-u"]');
  });
});
