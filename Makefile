OSXDIR=hello-1.0.0-osx

THIS_FILE := $(lastword $(MAKEFILE_LIST))

.DEFAULT_GOAL := help

run: ## Runs the code locally
	@echo 'Run the app locally'
	@echo '-------------------'
	@rm -fr $(OSXDIR)
	@mkdir -p $(OSXDIR)/lib/ruby
	@tar -xzf resources/traveling-ruby-20150715-2.2.2-osx.tar.gz -C $(OSXDIR)/lib/ruby
	@mkdir $(OSXDIR)/lib/app
	@cp hello_ruby/lib/hello.rb $(OSXDIR)/lib/app/hello.rb
	@cp resources/wrapper.sh $(OSXDIR)/hello
	@chmod +x $(OSXDIR)/hello
	@cd $(OSXDIR) && ./hello

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
