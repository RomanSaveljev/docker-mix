var MultiRun = require('../../lib/commands/multi-run');
var should = require('should');
var Run = require('../../lib/commands/run');

describe('MultiRun', function() {
  var dockerfile = [];
  var run = new Run('echo 123');
  it('constructor throws without parameters', function() {
    should(function() {new MultiRun()}).throw();
  });
  it('constructor expects parameters to be Run or MultiRun', function() {
    should(function() {new MultiRun(NaN)}).throw();
    should(function() {new MultiRun(run)}).not.throw();
    should(function() {new MultiRun(new MultiRun(run))}).not.throw();
  });
  it('renders all runs included', function() {
    var run2 = new Run('false');
    var run3 = new Run('true');
    var multiRun = new MultiRun(run2, run3);
    var multiRun2 = new MultiRun(multiRun, run);
    multiRun2.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN false && true && echo 123');
  });
  it('renders exec forms', function() {
    var run2 = new Run('wc', '-l');
    var run3 = new Run('uname', '-a');
    var multiRun = new MultiRun(run2, run3);
    multiRun.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN ["uname","-a"]');
    should(dockerfile.pop()).be.equal('RUN ["wc","-l"]');
  });
  it('mixes shell and exec forms', function() {
    var run2 = new Run('wc', '-l');
    var run3 = new Run('uname', '-a');
    var run4 = new Run('stat a.txt');
    var multiRun = new MultiRun(run2, run, run4, run3);
    multiRun.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN ["uname","-a"]');
    should(dockerfile.pop()).be.equal('RUN echo 123 && stat a.txt');
    should(dockerfile.pop()).be.equal('RUN ["wc","-l"]');
  });
  it('mixes shell and exec forms 2', function() {
    var run2 = new Run('wc', '-l');
    var multiRun = new MultiRun(run2, run);
    multiRun.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN echo 123');
    should(dockerfile.pop()).be.equal('RUN ["wc","-l"]');
  });
  it('mixes shell and exec forms 3', function() {
    var run2 = new Run('wc', '-l');
    var multiRun = new MultiRun(run, run2);
    multiRun.applyTo({}, dockerfile);
    should(dockerfile.pop()).be.equal('RUN ["wc","-l"]');
    should(dockerfile.pop()).be.equal('RUN echo 123');
  });
});
