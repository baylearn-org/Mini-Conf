PYTHON_FILES = main.py scripts/ chat/
JS_FILES = $(shell find static/js -name "*.js")
CSS_FILES = $(shell find static/css -name "*.css")
.PHONY: format-python format-web format run freeze format-check
TEMP_DEPLOY_BRANCH = "temp-gh-pages"

all: format-check

format-python:
	isort -rc $(PYTHON_FILES) --multi-line=3 --trailing-comma --force-grid-wrap=0 --use-parentheses --line-width=88
	black -t py37 $(PYTHON_FILES)

format-web:
	npx prettier $(JS_FILES) $(CSS_FILES) --write
	npx eslint $(JS_FILES) --fix

format: format-python format-web

run:
	export FLASK_DEBUG=True; export FLASK_DEVELOPMENT=True; python3 main.py sitedata/

freeze:
	python3 main.py sitedata/ --build

# check code format
format-check:
	(isort -rc $(PYTHON_FILES) --check-only --multi-line=3 --trailing-comma --force-grid-wrap=0 --use-parentheses --line-width=88) && (black -t py37 --check $(PYTHON_FILES)) || (echo "run \"make format\" to format the code"; exit 1)
	pylint -j0 $(PYTHON_FILES)
	mypy --show-error-codes $(PYTHON_FILES)
	npx prettier $(JS_FILES) $(CSS_FILES) --check
	npx eslint $(JS_FILES)
	@echo "format-check passed"

deploy: freeze
	cp -r build/* docs/
	git add -f docs
	git commit -am "Deploy on gh-pages"
	git push --force origin master
	@echo "Deployed to BayLearn site 🚀"

