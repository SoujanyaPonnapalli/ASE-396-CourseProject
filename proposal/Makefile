all:
	echo "starting"
	-pdflatex -interaction=nonstopmode main.tex > /tmp/log1
	echo "bibtex"
	-bibtex main
	echo "pdflatex step one"
	-pdflatex -interaction=nonstopmode main.tex > /tmp/log2
	echo "pdflatex step two"
	-pdflatex -interaction=nonstopmode main.tex > /tmp/log3

clean:
	-rm *.aux *.log *.out main.pdf *.fls *.synctex.* *fdb_* 