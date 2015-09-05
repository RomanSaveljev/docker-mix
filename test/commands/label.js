var Label = require('../../lib/commands/label');
var should = require('should');

describe('Label', function() {
  it('has LABEL keyword', function() {
    var label = new Label('a', 'b');
    should(label.keyword()).be.equal('LABEL');
  });
  it('combines', function() {
    var label = new Label('a', 'b');
    should(label.combines()).be.true();
  });
  it('does not override', function() {
    var label = new Label('a', 'b');
    should(label.overrides()).be.false();
  });
  it('constructor throws, when no parameters', function() {
    should(function() {new Label()}).throw();
  });
  it('constructor throws, when one parameter', function() {
    should(function() {new Label('c')}).throw();
  });
  it('formats both name and value', function() {
    var label = new Label('name', 'some-value');
    should(label.toString()).be.equal('LABEL "name"="some-value"');
  });
});
