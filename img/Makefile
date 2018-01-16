all: logo.svg logo.pdf logo-eng.svg logo-eng.pdf

logo.pdf: logo.tex
	lualatex $<

logo.svg: logo.pdf
	inkscape --without-gui --export-text-to-path --file=$<  --export-plain-svg=$@

logo-eng.pdf: logo-eng.tex
	lualatex $<

logo-eng.svg: logo-eng.pdf
	inkscape --without-gui --export-text-to-path --file=$<  --export-plain-svg=$@
