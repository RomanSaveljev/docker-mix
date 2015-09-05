MOCHA = ./node_modules/.bin/mocha

.PHONY : test build

build :
	@./node_modules/coffee-script/bin/coffee -c -o lib src

test : build
	@NODE_ENV=test $(MOCHA) --recursive
