var MultiExpose = require('../../lib/commands/multi-expose');
var should = require('should');
var Expose = require('../../lib/commands/expose');

describe('MultiExpose', function() {
  var expose = new Expose(1111);
  it('constructor throws without parameters', function() {
    should(function() {new MultiExpose()}).throw();
  });
  it('constructor expects parameters to be Expose or MultiExpose', function() {
    should(function() {new MultiExpose(8)}).throw();
    should(function() {new MultiExpose(expose)}).not.throw();
    should(function() {new MultiExpose(new MultiExpose(expose))}).not.throw();
  });
  it('renders all ports included', function() {
    var expose2 = new Expose(44);
    var expose3 = new Expose(45);
    var multiExpose = new MultiExpose(expose2, expose3);
    var multiExpose2 = new MultiExpose(multiExpose, expose);
    dockerfile = [];
    multiExpose2.applyTo({}, dockerfile);
    should(dockerfile[0]).be.equal('EXPOSE 44 45 1111');
  });
});
