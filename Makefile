PORT ?= 4000

serve_local:
	bundle exec jekyll serve --livereload --trace --port $(PORT)
