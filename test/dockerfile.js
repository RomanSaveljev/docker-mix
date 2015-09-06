var Dockerfile = require('../lib/dockerfile');
var should = require('should');
var From = require('../lib/commands/from');
var Maintainer = require('../lib/commands/maintainer');
var clone = require('clone');
var Entrypoint = require('../lib/commands/entrypoint');
var Run = require('../lib/commands/run');
var Expose = require('../lib/commands/expose');

function OverridingCommand(keyword) {
  this.overrides = function() {return true};
  this.combines = function() {return false};
  this.keyword = function() {return keyword};
}

function CombiningCommand(keyword) {
  this.overrides = function() {return false};
  this.combines = function() {return true};
  this.keyword = function() {return keyword};
}

describe('Dockerfile', function() {
  describe('basic', function() {
    it('empty gives empty string', function() {
      var dockerfile = new Dockerfile();
      should(dockerfile.toString()).be.equal('');
    });
  });
  describe('add()', function() {
    it('returns command object', function() {
      var dockerfile = new Dockerfile();
      var cmd = dockerfile.add(new CombiningCommand('A'));
      should(cmd).be.instanceof(CombiningCommand);
    });
    it('accepts overriding command', function() {
      var dockerfile = new Dockerfile();
      should(function() {dockerfile.add(new OverridingCommand('A'))}).not.throw();
    });
    it('accepts combining command', function() {
      var dockerfile = new Dockerfile();
      should(function() {dockerfile.add(new CombiningCommand('A'))}).not.throw();
    });
    it('throws, when override must be used', function() {
      var dockerfile = new Dockerfile();
      var override = new OverridingCommand('OVERRIDE');
      dockerfile.add(override);
      should(function() {dockerfile.add(clone(override))}).throw();
    });
    it('accepts overridable with different keywords', function() {
      var dockerfile = new Dockerfile();
      var a = new OverridingCommand('A');
      var b = new OverridingCommand('B');
      dockerfile.add(a);
      should(function() {dockerfile.add(b)}).not.throw();
    });
    it('accepts combining commands with the same keyword', function() {
      var dockerfile = new Dockerfile();
      var a = new CombiningCommand('ONE');
      var b = new CombiningCommand('ONE');
      dockerfile.add(a);
      should(function() {dockerfile.add(b)}).not.throw();
    });
  });
  describe('override()', function() {
    it('returns command object', function() {
      var dockerfile = new Dockerfile();
      var cmd = dockerfile.override(new OverridingCommand('A'));
      should(cmd).be.instanceof(OverridingCommand);
    });
    it('increases count, if new', function() {
      var dockerfile = new Dockerfile();
      var cmd = dockerfile.override(new OverridingCommand('A'));
      should(dockerfile.count()).be.equal(1);
    });
    it('refuses combining command', function() {
      var dockerfile = new Dockerfile();
      should(function() {dockerfile.override(new CombiningCommand('A'))}).throw();
    });
    it('accepts override even if nothing to override', function() {
      var dockerfile = new Dockerfile();
      dockerfile.override(new OverridingCommand('A'));
      should(function() {dockerfile.override(new OverridingCommand('A'))}).not.throw();
    });
    it('accepts override', function() {
      var dockerfile = new Dockerfile();
      var override = new OverridingCommand('OVERRIDE');
      dockerfile.override(override);
      should(function() {dockerfile.override(clone(override))}).not.throw();
    });
    it('keeps count, if replaces', function() {
      var dockerfile = new Dockerfile();
      var override = dockerfile.override(new OverridingCommand('OVERRIDE'));
      var count = dockerfile.count();
      dockerfile.override(clone(override));
      should(dockerfile.count()).be.equal(count);
    });
  });
  describe('command priorities', function() {
    it('FROM has higher priority than MAINTAINER', function() {
      var dockerfile = new Dockerfile();
      dockerfile.add(new Maintainer('Arnaud Guanod'));
      dockerfile.add(new From('debian', 'jessie'));
      var lines = dockerfile.toString().split("\n");
      should(lines[0]).be.equal("FROM debian:jessie");
      should(lines[1]).be.equal("MAINTAINER Arnaud Guanod");
    });
  });
  describe('doAfter()', function() {
    it('returns command object', function() {
      var dockerfile = new Dockerfile();
      var a = dockerfile.add(new CombiningCommand('A'));
      var b = dockerfile.add(new CombiningCommand('B'));
      should(b.doAfter(a)).be.equal(b);
    });
  });
  describe('doBefore()', function() {
    it('returns command object', function() {
      var dockerfile = new Dockerfile();
      var a = dockerfile.add(new CombiningCommand('A'));
      var b = dockerfile.add(new CombiningCommand('B'));
      should(a.doBefore(b)).be.equal(a);
    });
  });
  describe('dependencies', function() {
    it('dependencies override priorities', function() {
      var dockerfile = new Dockerfile();
      var from = dockerfile.add(new From('debian', 'jessie'));
      var maintainer = dockerfile.add(new Maintainer('John'));
      from.doAfter(maintainer);
      var lines = dockerfile.toString().split("\n");
      should(lines[0]).be.equal('MAINTAINER John');
      should(lines[1]).be.equal('FROM debian:jessie');
    });
    it('dependencies follow depth-first', function() {
      var dockerfile = new Dockerfile();
      var from = dockerfile.add(new From('ubuntu', 'trusty'));
      var entrypoint = dockerfile.add(new Entrypoint('echo 123')).doAfter(from);
      var run = dockerfile.add(new Run('wget http://www.google.com')).doAfter(entrypoint);
      var maintainer = dockerfile.add(new Maintainer('Me Me'));
      var lines = dockerfile.toString().split("\n");
      should(lines[0]).be.equal('FROM ubuntu:trusty');
      should(lines[1]).be.equal('ENTRYPOINT echo 123');
      should(lines[2]).be.equal('RUN wget http://www.google.com');
      should(lines[3]).be.equal('MAINTAINER Me Me');
    });
    it('understands override', function() {
      var dockerfile = new Dockerfile();
      var maintainer = dockerfile.override(new Maintainer('Me'));
      var from = dockerfile.override(new From('scratch'));
      var expose = dockerfile.add(new Expose(56)).doAfter(from);
      var expose2 = dockerfile.add(new Expose(57)).doAfter(maintainer);
      dockerfile.override(new From('busybox'));
      var lines = dockerfile.toString().split("\n");
      should(lines[0]).be.equal('FROM busybox:latest');
      should(lines[1]).be.equal('EXPOSE 56');
      should(lines[2]).be.equal('MAINTAINER Me');
      should(lines[3]).be.equal('EXPOSE 57');
    });
  });
  describe('aggregate', function() {
    it('works for EXPOSE', function() {
      var dockerfile = new Dockerfile();
      var expose1 = dockerfile.add(new Expose(45));
      var from = dockerfile.add(new From('ubuntu', 'utopic'));
      var expose2 = dockerfile.add(new Expose(46));
      var lines = dockerfile.toString().split("\n");
      should(lines[0]).be.equal('FROM ubuntu:utopic');
      should(lines[1]).be.equal('EXPOSE 45 46');
    });
    it('respects dependencies', function() {
      var dockerfile = new Dockerfile();
      var from = dockerfile.add(new From('scratch'));
      var expose1 = dockerfile.add(new Expose(45)).doAfter(from);
      var maintainer = dockerfile.add(new Maintainer('Me'));
      var expose2 = dockerfile.add(new Expose(46)).doAfter(maintainer);
      var lines = dockerfile.toString().split("\n");
      should(lines[0]).be.equal('FROM scratch:latest');
      should(lines[1]).be.equal('EXPOSE 45');
      should(lines[2]).be.equal('MAINTAINER Me');
      should(lines[3]).be.equal('EXPOSE 46');
    });
    it('optimizes for dependencies', function() {
      var dockerfile = new Dockerfile();
      var expose1 = dockerfile.add(new Expose(45));
      var from = dockerfile.add(new From('scratch'));
      var expose2 = dockerfile.add(new Expose(46)).doAfter(from);
      var lines = dockerfile.toString().split("\n");
      should(lines[0]).be.equal('FROM scratch:latest');
      should(lines[1]).be.equal('EXPOSE 45 46');
    });
  });
});
