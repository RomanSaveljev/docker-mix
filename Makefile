ifeq ($(TRAVIS_BUILD),)
 REPORTER ?= nyan
else
 REPORTER ?= tap
endif

FILTER ?= .+
MOCHA = ./node_modules/.bin/mocha
COFFEE = ./node_modules/.bin/coffee

.PHONY : test build

build :
	pwd
	@$(COFFEE) -c -o lib src

test : build
	@NODE_ENV=test $(MOCHA) --reporter $(REPORTER) --recursive -g '$(FILTER)'
