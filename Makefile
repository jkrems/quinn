SRC = $(shell find src -name "*.js" -type f | sort)
DIST = $(SRC:src/%.js=dist/%.js)

COMPILE = ./build/compile.js

default: build

# Upstream modules
.PHONY: quinn-respond
quinn-respond:
	@cd node_modules/quinn-respond && make build

.PHONY: build test check-checkout-clean clean clean-dist lint
build: $(DIST) quinn-respond

dist/%.js: src/%.js build/compile.js node_modules
	@echo "Compiling $< -> $@"
	@dirname "$@" | xargs mkdir -p
	@$(COMPILE) <"$<" >"$@"

# This will fail if there are unstaged changes in the checkout
check-checkout-clean:
	git diff --exit-code

test: build node_modules
	@./node_modules/.bin/mocha

node_modules: package.json
	@npm install

lint: build
	@./node_modules/.bin/jshint src

clean:
	rm -rf dist

watch: node_modules
	@./node_modules/.bin/reakt -g "{src,test,build}/**/*.js" "make test"
