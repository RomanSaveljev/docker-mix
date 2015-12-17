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
	@which '$(COFFEE)' >/dev/null || echo "$(COFFEE) must be globally installed, e.g. 'npm install coffee-script -g'" 1>&2
	@$(COFFEE) -c -o lib src

test : build
	@NODE_ENV=test $(MOCHA) --reporter $(REPORTER) --recursive -g '$(FILTER)'
