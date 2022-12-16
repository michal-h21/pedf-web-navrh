all: logo.svg logo.pdf logo-eng.svg logo-eng.pdf qrplatba.svg

logo.pdf: logo.tex
	lualatex $<

logo.svg: logo.pdf
	pdf2svg  $< $@

logo-eng.pdf: logo-eng.tex
	lualatex $<

logo-eng.svg: logo-eng.pdf
	pdf2svg  $< $@

qrplatba.svg: qrplatba.pdf
	pdf2svg $< $@

qrplatba.pdf: qrplatba.tex
	lualatex $<
