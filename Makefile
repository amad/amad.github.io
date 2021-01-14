.PHONY: help update assets pages

all: update

help:
	@echo 'make serve: Serve on the PHP development server'
	@echo 'make pages: Build pages'
	@echo 'make assets: Build assets'

assets:
	sass --style compressed --update assets/scss/app.scss:assets/css/app.min.css

pages:
	php bin/make

update:
	composer update --no-dev -o
	make assets
	make pages

serve:
	php -S localhost:8000
