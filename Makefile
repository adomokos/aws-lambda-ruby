OSXDIR=hello-1.0.0-osx
LAMBDADIR=hello-1.0.0-linux-x86_64

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
	@cp -pR hello_ruby/vendor $(OSXDIR)/lib/
	@rm -f $(OSXDIR)/lib/vendor/*/*/cache/*
	@mkdir -p $(OSXDIR)/lib/vendor/.bundle
	@cp resources/bundler-config $(OSXDIR)/lib/vendor/.bundle/config
	@cp hello_ruby/Gemfile $(OSXDIR)/lib/vendor/
	@cp hello_ruby/Gemfile.lock $(OSXDIR)/lib/vendor/
	@cp resources/wrapper.sh $(OSXDIR)/hello
	@chmod +x $(OSXDIR)/hello
	@cd $(OSXDIR) && ./hello

package: ## Package the code for AWS Lambda
	@echo 'Package the app for deploy'
	@echo '--------------------------'
	@rm -fr $(LAMBDADIR)
	@rm -fr deploy
	@mkdir -p $(LAMBDADIR)/lib/ruby
	@tar -xzf resources/traveling-ruby-20150715-2.2.2-linux-x86_64.tar.gz -C $(LAMBDADIR)/lib/ruby
	@mkdir $(LAMBDADIR)/lib/app
	@cp hello_ruby/lib/hello.rb $(LAMBDADIR)/lib/app/hello.rb
	@cp -pR hello_ruby/vendor $(LAMBDADIR)/lib/
	@rm -f $(LAMBDADIR)/lib/vendor/*/*/cache/*
	@mkdir -p $(LAMBDADIR)/lib/vendor/.bundle
	@cp resources/bundler-config $(LAMBDADIR)/lib/vendor/.bundle/config
	@cp hello_ruby/Gemfile $(LAMBDADIR)/lib/vendor/
	@cp hello_ruby/Gemfile.lock $(LAMBDADIR)/lib/vendor/
	@cp resources/wrapper.sh $(LAMBDADIR)/hello
	@chmod +x $(LAMBDADIR)/hello
	@cp resources/index.js $(LAMBDADIR)/
	@cd $(LAMBDADIR) && zip -r hello_ruby.zip hello index.js lib/ > /dev/null
	@mkdir deploy
	@cd $(LAMBDADIR) && mv hello_ruby.zip ../deploy/
	@echo '... Done.'

create: ## Creates an AWS lambda function
	aws lambda create-function \
		--function-name HelloFromRuby \
		--handler index.handler \
		--runtime nodejs4.3 \
		--memory 512 \
		--timeout 10 \
		--description "Saying hello from MRI Ruby" \
		--role arn:aws:iam::___xyz___:role/lambda_basic_execution \
		--zip-file fileb://./deploy/hello_ruby.zip

publish: package ## Deploys the latest version to AWS
	aws lambda update-function-code \
		--function-name HelloFromRuby \
		--zip-file fileb://./deploy/hello_ruby.zip

delete: ## Removes the Lambda
	aws lambda delete-function --function-name HelloFromRuby

invoke: ## Invoke the AWS Lambda in the command line
	rm -fr tmp && mkdir tmp
	aws lambda invoke \
	--invocation-type RequestResponse \
	--function-name HelloFromRuby \
	--log-type Tail \
	--region us-east-1 \
	--payload '{"name":"John Adam Smith"}' \
	tmp/outfile.txt \
	| jq -r '.LogResult' | base64 -D

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
