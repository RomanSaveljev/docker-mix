var Add = require('../../lib/commands/add');
var should = require('should');

describe('Add', function() {
  it('has COPY keyword', function() {
    var add = new Add('a/b/c', '/d/e');
    should(add.keyword()).be.equal('ADD');
  });
  it('does not combine', function() {
    var add = new Add('a/b/c', '/d/e');
    should(add.combines()).be.false();
  });
  it('does not override', function() {
    var add = new Add('a/b/c', '/d/e');
    should(add.overrides()).be.false();
  });
  it('uses src and dst', function() {
    var add = new Add('a/b/c', '/d/e');
    should(add.toString()).be.equal('ADD ["a/b/c","/d/e"]');
  });
  it('constructor throws without parameters', function() {
    should(function() {new Add()}).throw();
  });
  it('constructor throws with one parameter', function() {
    should(function() {new Add('a/b/c')}).throw();
  });
});
