var Label = require('../../lib/commands/label');
var should = require('should');

describe('Label', function() {
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
});
