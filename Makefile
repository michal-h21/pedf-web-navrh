
.Phony: upload

all: style.css index.html mini-knihovna.css upload

style.css: style.lua
	lua style.lua > style.css

index.html: template.lua
	lua template.lua > index.html


mini-knihovna.css: mini.css/src/flavors/mini-knihovna.scss
	scss mini.css/src/flavors/mini-knihovna.scss > mini-knihovna.css

upload:
	scp mini-knihovna.css style.css index.html beta:/var/www/html/navrh/
	scp img/*.* beta:/var/www/html/navrh/img/
	
