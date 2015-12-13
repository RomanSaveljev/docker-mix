ifeq ($(TRAVIS_BUILD),)
 REPORTER ?= nyan
else
 REPORTER ?= tap
endif

FILTER ?= .+
MOCHA = ./node_modules/.bin/mocha

.PHONY : test build

build :
	@./node_modules/.bin/coffee -c -o lib src

test : build
	@NODE_ENV=test $(MOCHA) --reporter $(REPORTER) --recursive -g '$(FILTER)'
