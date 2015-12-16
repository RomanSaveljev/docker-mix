var Dockerfile = require('../lib/dockerfile');
var should = require('should');
var From = require('../lib/commands/from');
var Maintainer = require('../lib/commands/maintainer');
var clone = require('clone');
var Entrypoint = require('../lib/commands/entrypoint');
var Run = require('../lib/commands/run');
var Expose = require('../lib/commands/expose');

function createOverridingCommand() {
  var ctor = function() {
    this.overrides = function() {return true};
    this.combines = function() {return false};
  };
  return new ctor();
}

function createCombiningCommand() {
  var ctor = function() {
    this.overrides = function() {return false};
    this.combines = function() {return true};
  };
  return new ctor();
}

describe('Dockerfile', function() {
  var contents = [];
  describe('basic', function() {
    it('starts with empty commands array', function() {
      var dockerfile = new Dockerfile();
      should(dockerfile.count()).be.equal(0);
    });
  });
  describe('add()', function() {
    it('returns command object', function() {
      var dockerfile = new Dockerfile();
      var combine = createCombiningCommand();
      var cmd = dockerfile.add(combine);
      should(cmd).be.equal(combine);
    });
    it('accepts overriding command', function() {
      var dockerfile = new Dockerfile();
      should(function() {dockerfile.add(createOverridingCommand())}).not.throw();
    });
    it('accepts combining command', function() {
      var dockerfile = new Dockerfile();
      should(function() {dockerfile.add(createCombiningCommand())}).not.throw();
    });
    it('throws, when override must be used', function() {
      var dockerfile = new Dockerfile();
      var override = createOverridingCommand();
      dockerfile.add(override);
      should(function() {dockerfile.add(clone(override))}).throw();
    });
    it('accepts overridable with different keywords', function() {
      var dockerfile = new Dockerfile();
      var a = createOverridingCommand();
      var b = createOverridingCommand();
      dockerfile.add(a);
      should(function() {dockerfile.add(b)}).not.throw();
    });
    it('accepts two same combining commands', function() {
      var dockerfile = new Dockerfile();
      var a = createCombiningCommand();
      var b = clone(a);
      dockerfile.add(a);
      should(function() {dockerfile.add(b)}).not.throw();
    });
    it('understands labels', function() {
      var dockerfile = new Dockerfile();
      var a = createCombiningCommand();
      dockerfile.add(a, "MY_LABEL");
      should(dockerfile.findByLabel("MY_LABEL")).be.equal(a)
    });
  });
  describe('override()', function() {
    it('returns command object', function() {
      var dockerfile = new Dockerfile();
      var overriding = createOverridingCommand();
      var cmd = dockerfile.override(overriding);
      should(cmd).be.equal(overriding);
    });
    it('increases count, if new', function() {
      var dockerfile = new Dockerfile();
      var cmd = dockerfile.override(createOverridingCommand());
      should(dockerfile.count()).be.equal(1);
    });
    it('refuses combining command', function() {
      var dockerfile = new Dockerfile();
      should(function() {dockerfile.override(createCombiningCommand())}).throw();
    });
    it('accepts override even if nothing to override', function() {
      var dockerfile = new Dockerfile();
      var overriding = createOverridingCommand();
      dockerfile.override(overriding);
      should(function() {dockerfile.override(clone(overriding))}).not.throw();
    });
    it('accepts override', function() {
      var dockerfile = new Dockerfile();
      var override = createOverridingCommand();
      dockerfile.override(override);
      should(function() {dockerfile.override(clone(override))}).not.throw();
    });
    it('keeps count, if replaces', function() {
      var dockerfile = new Dockerfile();
      var override = dockerfile.override(createOverridingCommand());
      var count = dockerfile.count();
      dockerfile.override(clone(override));
      should(dockerfile.count()).be.equal(count);
    });
    describe('returns augmented command', function() {
      it('when new', function() {
        var dockerfile = new Dockerfile();
        var override = createOverridingCommand();
        ret = dockerfile.override(clone(override));
        should(ret).be.ok();
        should(ret.next).be.Function();
        should(ret.doAfter).be.Function();
        should(ret.doBefore).be.Function();
        should(ret.doBefore).be.Function();
      });
      it('when exists', function() {
        var dockerfile = new Dockerfile();
        var override = createOverridingCommand();
        dockerfile.override(clone(override));
        ret = dockerfile.override(clone(override));
        should(ret).be.ok();
        should(ret.next).be.Function();
        should(ret.doAfter).be.Function();
        should(ret.doBefore).be.Function();
      });
    });
    it('restores labels', function() {
      var dockerfile = new Dockerfile();
      var override = createOverridingCommand();
      var first = dockerfile.override(clone(override), "label");
      should(dockerfile.findByLabel("label")).be.equal(first);
      var second = dockerfile.override(clone(override), "label");
      should(dockerfile.findByLabel("label")).be.equal(second);
    });
  });
  describe('command priorities', function() {
    it('FROM has higher priority than MAINTAINER', function() {
      var dockerfile = new Dockerfile();
      dockerfile.add(new Maintainer('Arnaud Guanod'));
      dockerfile.add(new From('debian', 'jessie'));
      var lines = []
      dockerfile.build(lines);
      var idxFrom = lines.indexOf("FROM debian:jessie");
      should(idxFrom).not.be.equal(-1);
      var idxMaintainer = lines.indexOf("MAINTAINER Arnaud Guanod");
      should(idxMaintainer).not.be.equal(-1);
      should(idxFrom).be.lessThan(idxMaintainer);
    });
  });
  describe('doAfter()', function() {
    it('returns command object', function() {
      var dockerfile = new Dockerfile();
      var a = dockerfile.add(createCombiningCommand());
      var b = dockerfile.add(createCombiningCommand());
      should(b.doAfter(a)).be.equal(b);
    });
  });
  describe('doBefore()', function() {
    it('returns command object', function() {
      var dockerfile = new Dockerfile();
      var a = dockerfile.add(createCombiningCommand());
      var b = dockerfile.add(createCombiningCommand());
      should(a.doBefore(b)).be.equal(a);
    });
  });
  describe('dependencies', function() {
    it('override priorities', function() {
      var dockerfile = new Dockerfile();
      var from = dockerfile.add(new From('debian', 'jessie'));
      var maintainer = dockerfile.add(new Maintainer('John'));
      var run = dockerfile.add(new Run('true'));
      maintainer.doAfter(run);
      var lines = [];
      dockerfile.build(lines);
      var idxFrom = lines.indexOf('FROM debian:jessie');
      should(idxFrom).not.be.equal(-1);
      var idxMaintainer = lines.indexOf('MAINTAINER John');
      should(idxMaintainer).not.be.equal(-1);
      var idxRun = lines.indexOf('RUN true');
      should(idxRun).not.be.equal(-1);
      should(idxFrom).be.lessThan(idxRun);
      should(idxRun).be.lessThan(idxMaintainer);
    });
    it('follow depth-first', function() {
      var dockerfile = new Dockerfile();
      var from = dockerfile.add(new From('ubuntu', 'trusty'));
      var entrypoint = dockerfile.add(new Entrypoint('echo 123')).doAfter(from);
      var run = dockerfile.add(new Run('wget http://www.google.com')).doAfter(entrypoint);
      var maintainer = dockerfile.add(new Maintainer('Me Me'));
      var lines = [];
      dockerfile.build(lines);
      var idxFrom = lines.indexOf('FROM ubuntu:trusty');
      should(idxFrom).not.be.equal(-1);
      var idxEntrypoint = lines.indexOf('ENTRYPOINT echo 123');
      should(idxEntrypoint).not.be.equal(-1);
      var idxRun = lines.indexOf('RUN wget http://www.google.com');
      should(idxRun).not.be.equal(-1);
      var idxMaintainer = lines.indexOf('MAINTAINER Me Me');
      should(idxMaintainer).not.be.equal(-1);
      should(idxFrom).be.lessThan(idxEntrypoint);
      should(idxEntrypoint).be.lessThan(idxRun);
      should(idxRun).be.lessThan(idxMaintainer);
    });
    it('understands override', function() {
      var dockerfile = new Dockerfile();
      var run = dockerfile.add(new Run('uname -a'));
      var from = dockerfile.override(new From('scratch'));
      var expose = dockerfile.add(new Expose(56)).doAfter(from);
      var expose2 = dockerfile.add(new Expose(57)).doAfter(run);
      dockerfile.override(new From('busybox'));
      var lines = [];
      dockerfile.build(lines);
      var idxFrom = lines.indexOf('FROM busybox:latest');
      should(idxFrom).not.be.equal(-1);
      var idxExpose = lines.indexOf('EXPOSE 56');
      should(idxExpose).not.be.equal(-1);
      var idxRun = lines.indexOf('RUN uname -a');
      should(idxRun).not.be.equal(-1);
      var idxExpose2 = lines.indexOf('EXPOSE 57');
      should(idxExpose2).not.be.equal(-1);
      should(idxFrom).be.lessThan(idxExpose);
      should(idxExpose).be.lessThan(idxRun);
      should(idxRun).be.lessThan(idxExpose2);
    });
  });
  describe('aggregate', function() {
    it('works for EXPOSE', function() {
      var dockerfile = new Dockerfile();
      var expose1 = dockerfile.add(new Expose(45));
      var from = dockerfile.add(new From('ubuntu', 'utopic'));
      var expose2 = dockerfile.add(new Expose(46));
      var lines = []
      dockerfile.build(lines);
      var idxFrom = lines.indexOf('FROM ubuntu:utopic');
      should(idxFrom).not.be.equal(-1);
      var idxExpose = lines.indexOf('EXPOSE 45 46');
      should(idxExpose).not.be.equal(-1);
      should(idxFrom).be.lessThan(idxExpose);
    });
    it('respects dependencies', function() {
      var dockerfile = new Dockerfile();
      var from = dockerfile.add(new From('scratch'));
      var expose1 = dockerfile.add(new Expose(45)).doAfter(from);
      var maintainer = dockerfile.add(new Maintainer('Me'));
      var expose2 = dockerfile.add(new Expose(46)).doAfter(maintainer);
      var lines = [];
      dockerfile.build(lines);
      var idxFrom = lines.indexOf('FROM scratch:latest');
      should(idxFrom).not.be.equal(-1);
      var idxExpose = lines.indexOf('EXPOSE 45');
      should(idxExpose).not.be.equal(-1);
      var idxMaintainer = lines.indexOf('MAINTAINER Me');
      should(idxMaintainer).not.be.equal(-1);
      var idxExpose2 = lines.indexOf('EXPOSE 46');
      should(idxExpose2).not.be.equal(-1);
      should(idxFrom).be.lessThan(idxExpose);
      should(idxExpose).be.lessThan(idxMaintainer);
      should(idxMaintainer).be.lessThan(idxExpose2);
    });
    it('optimizes for dependencies', function() {
      var dockerfile = new Dockerfile();
      var expose1 = dockerfile.add(new Expose(45));
      var from = dockerfile.add(new From('scratch'));
      var expose2 = dockerfile.add(new Expose(46)).doAfter(from);
      var lines = [];
      dockerfile.build(lines);
      var idxFrom = lines.indexOf('FROM scratch:latest');
      should(idxFrom).not.be.equal(-1);
      var idxExpose = lines.indexOf('EXPOSE 46 45');
      should(idxExpose).not.be.equal(-1);
      should(idxFrom).be.lessThan(idxExpose);
    });
  });
  describe('tight group', function() {
    var dockerfile, from;
    beforeEach(function() {
      dockerfile = new Dockerfile();
      from = dockerfile.add(new From('debian'));
    });
    it('command add() links', function() {
      var command = dockerfile.add(new Expose(1));
      var command2 = command.next(new Expose(2));
      should(command2.after).be.equal(command);
    });
    it('creates links', function() {
      var command = dockerfile.add(new Expose(14));
      var command2 = command.next(new Expose(15));
      var command3 = command2.next(new Expose(16));
      var command4 = command3.next(new Expose(17));
      dockerfile.build(contents);
      should(contents.pop()).be.equal('EXPOSE 14 15 16 17');
      should(command2.after).be.equal(command);
      should(command3.after).be.equal(command2);
      should(command4.after).be.equal(command3);
    });
    it('doAfter() updates first element', function() {
      var command = dockerfile.add(new Expose(14));
      var command2 = command.next(new Expose(15));
      var command3 = command2.next(new Expose(16));
      var command4 = command3.next(new Expose(17));
      should(command.after).be.undefined();
      command.doAfter(from);
      should(command.after).be.equal(from);
      delete command.after;
      command2.doAfter(from);
      should(command2.after).be.equal(command);
      should(command.after).be.equal(from);
      delete command.after;
      command3.doAfter(from);
      should(command3.after).be.equal(command2);
      should(command.after).be.equal(from);
      delete command.after;
      command4.doAfter(from);
      should(command4.after).be.equal(command3);
      should(command.after).be.equal(from);
    });
    it('doBefore() works individually for each element', function() {
      var command = dockerfile.add(new Expose(14));
      var command2 = command.next(new Expose(15));
      var command3 = command2.next(new Expose(16));
      var command4 = command3.next(new Expose(17));
      command.doBefore(from);
      should(from.after).be.equal(command);
      command2.doBefore(from);
      should(from.after).be.equal(command2);
      command3.doBefore(from);
      should(from.after).be.equal(command3);
      command4.doBefore(from);
      should(from.after).be.equal(command4);
    });
    it('next() understands labels', function() {
      var command = dockerfile
        .add(new Expose(14))
        .next(new Expose(15), "MY_LABEL");
      should(dockerfile.findByLabel("MY_LABEL")).be.equal(command)
    });
  });
});
