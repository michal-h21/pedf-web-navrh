all: logo.svg logo.pdf

logo.pdf: logo.tex
	lualatex $<

logo.svg: logo.pdf
	inkscape --without-gui --export-text-to-path --file=$<  --export-plain-svg=$@
