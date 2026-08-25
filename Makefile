J=julia +1.11.4
L=pdflatex
X=xelatex
B=biber

.PHONY : all ms pdf

all : pdf

ms : editedskeleton/chapters/05-content.tex

pdf : chapter05.pdf

editedskeleton/chapters/05-content.tex : md/henrichapter.md md/replacements-pre md/replacements-post md/preamble.tex md/references.bib tables/experiment-parameters.tex tables/bifurcation.tex tables/latshape.tex tables/onerun.tex tables/list_of_parameters.tex tables/data-afrikaans.tex tables/data-aps.tex tables/optimize-bounds.tex tex/05.tex tex/05-abs.tex
	cp tex/05.tex editedskeleton/chapters
	cp tex/05-abs.tex editedskeleton/chapters
	cp tex/localcommands.tex editedskeleton
	cp tex/localpackages.tex editedskeleton
	cp md/references.bib editedskeleton/localbibliography.bib
	cd md; sed -f replacements-pre henrichapter.md | perl include.pl | pandoc --lua-filter=include-files.lua -f markdown+pipe_tables+table_captions -t latex --filter pandoc-xnos --biblatex | sed -f replacements-post > ../editedskeleton/chapters/05-content.tex

chapter05.pdf : editedskeleton/chapters/05-content.tex tex/05.tex tex/05-abs.tex tex/main.tex tex/localcommands.tex tex/localpackages.tex plots/bifu.pdf plots/latshape.pdf plots/lat.pdf plots/ts.pdf plots/venn.pdf plots/lattice.pdf plots/experiment.pdf plots/example-trajectories.pdf plots/fitted-demographics.pdf plots/optimized-simulations.pdf plots/distros.pdf plots/abc-APS.pdf plots/abc-Afrikaans.pdf
	cp tex/05.tex editedskeleton/chapters
	cp tex/05-abs.tex editedskeleton/chapters
	cp tex/main.tex editedskeleton
	cp tex/localcommands.tex editedskeleton
	cp tex/localpackages.tex editedskeleton
	mkdir -p editedskeleton/figures/ch5
	cp plots/*.pdf editedskeleton/figures/ch5
	cd editedskeleton; \
		$X -interaction nonstopmode main; \
		$B 05; \
		$X -interaction nonstopmode main; \
		$X -interaction nonstopmode main; \
		$X -interaction nonstopmode main; \
		cp main.pdf ../chapter05.pdf

plots/abc-APS.pdf plots/abc-Afrikaans.pdf &: jl/plot_abc.jl output/abc_APS.jls output/abc_Afrikaans.jls
	cd jl; $J --project=. plot_abc.jl

plots/distros.pdf : jl/plot_distros.jl
	cd jl; $J --project=. plot_distros.jl

tables/optimize-bounds.tex : jl/print_lbsubs.jl jl/optimize_pars.jl jl/parameters/list_of_parameters.json
	cd jl; $J --project=. print_lbsubs.jl

tables/data-afrikaans.tex tables/data-aps.tex &: jl/print_demographics.jl data/afrikaans.csv data/aps.csv
	cd jl; $J --project=. print_demographics.jl

tables/bifurcation.tex tables/latshape.tex tables/onerun.tex tables/list_of_parameters.tex &: jl/Parameterizer.jl jl/print_parameters.jl jl/parameters/list_of_parameters.json jl/parameters/onerun.json jl/parameters/bifurcation.json jl/parameters/bifurcation_long.json jl/parameters/latshape.json
	cd jl; $J --project=. print_parameters.jl

plots/bifu.pdf : jl/bifuheatmap_trueprop_long.jl output/bifurcation_long.csv
	cd jl; $J --project=. bifuheatmap_trueprop_long.jl

plots/latshape.pdf : jl/latshapeheatmap.jl output/latshape.csv
	cd jl; $J --project=. latshapeheatmap.jl

plots/fitted-demographics.pdf plots/optimized-simulations.pdf &: jl/plot_optimized.jl output/sweep_APS_abc_*.csv output/sweep_Afrikaans_abc_*.csv
	cd jl; $J --project=. plot_optimized.jl

plots/venn.pdf : tikz/venn.tex
	cd tikz; $L -output-directory=../plots venn.tex

plots/lattice.pdf : tikz/lattice.tex
	cd tikz; $L -output-directory=../plots lattice.tex

