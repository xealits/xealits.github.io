PORT ?= 4000

serve_local:
	bundle exec jekyll serve --livereload --trace --port $(PORT)

%-800w-compressed.jpeg: %.jpeg
	sips --resampleWidth 800 -s format jpeg -s formatOptions 10 $< --out $@
