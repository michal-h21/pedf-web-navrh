all: style.css index.html

style.css: style.lua
	lua style.lua > style.css

index.html: template.lua
	lua template.lua > index.html


