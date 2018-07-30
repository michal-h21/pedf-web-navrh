
.Phony: upload generate serve

all: style.css mini-knihovna.css html/eiz-pedf.html generate upload 

style.css: style.lua
	lua style.lua > style.css

# index.html: template.lua
	# lua template.lua > index.html

data/eiz.csv: data/eiz.xlsx
	in2csv $< > $@

html/eiz-pedf.html: data/eiz.csv src/eiz.lua
	lua src/eiz.lua < $< > $@

mini-knihovna.css: mini.css/src/flavors/mini-knihovna.scss
	scss mini.css/src/flavors/mini-knihovna.scss > mini-knihovna.css

generate:
	texlua web.lua
	# cp index.html www
	cp mini-knihovna.css media.css style.css www
	mkdir www/img
	mkdir www/js
	cp img/*.svg www/img/
	cp js/*.* www/js/

upload:
	cd www && rsync -auvz --checksum . knihovna-new:/home/hoftich/nginx/html/
	# cd www && rsync -auvz --checksum . beta:/var/www/html/
	# scp mini-knihovna.css style.css index.html beta:/var/www/html/navrh/
	# scp img/*.* beta:/var/www/html/navrh/img/
	
serve: generate
	python server.py
