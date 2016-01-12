ifneq ($(shell test -t 1 && echo TTY),TTY)
 TRAVIS_BUILD ?= 1
endif

ifeq ($(TRAVIS_BUILD),)
 REPORTER ?= nyan
else
 REPORTER ?= tap
endif

FILTER ?= .+
MOCHA = ./node_modules/.bin/mocha
COFFEE = coffee

.PHONY : test build

build :
	@$(COFFEE) -c -o lib src

test : build
	@NODE_ENV=test $(MOCHA) --reporter $(REPORTER) --recursive -g '$(FILTER)'
