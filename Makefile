
.Phony: upload generate

all: style.css index.html mini-knihovna.css generate upload 

style.css: style.lua
	lua style.lua > style.css

# index.html: template.lua
	# lua template.lua > index.html


mini-knihovna.css: mini.css/src/flavors/mini-knihovna.scss
	scss mini.css/src/flavors/mini-knihovna.scss > mini-knihovna.css

generate:
	texlua web.lua
	# cp index.html www
	cp mini-knihovna.css media.css style.css www
	mkdir www/img
	cp img/*.svg www/img/

upload:
	cd www && rsync -avz . beta:/var/www/html/navrh/
	# scp mini-knihovna.css style.css index.html beta:/var/www/html/navrh/
	# scp img/*.* beta:/var/www/html/navrh/img/
	

