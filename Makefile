ifneq ($(TRAVIS),)
 REPORTER ?= tap
endif

ifneq ($(JENKINS_URL),)
 REPORTER ?= tap
endif

ifeq ($(REPORTER),)
 REPORTER ?= dot
endif

FILTER ?= .+
MOCHA = mocha
COFFEE = coffee

.PHONY : test build

build :
	@$(COFFEE) -c -o lib src

test : build
	@$(COFFEE) -c test
	@NODE_ENV=test $(MOCHA) --reporter $(REPORTER) --recursive -g '$(FILTER)'

cov-all: build
	@NODE_ENV=test $(MOCHA) --reporter html-cov --require blanket --recursive
