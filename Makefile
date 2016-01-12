ifneq ($(TRAVIS_BUILD),)
 REPORTER ?= tap
endif

ifneq ($(JENKINS_URL),)
 REPORTER ?= tap
endif

ifeq ($(REPORTER),)
 REPORTER = nyan
endif

FILTER ?= .+
MOCHA = mocha
COFFEE = coffee

.PHONY : test build

build :
	@$(COFFEE) -c -o lib src

test : build
	@NODE_ENV=test $(MOCHA) --reporter $(REPORTER) --recursive -g '$(FILTER)'
