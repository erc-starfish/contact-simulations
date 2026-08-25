# bookchapter

Data and code for chapter 5 of the book *Sociolinguistic typology and responsive features in syntactic history* (eds. Walkden et al.).


## Dependencies

Julia version 1.11.4, bash shell, GNU make.

To install required packages, launch Julia REPL inside the `jl` folder. In pkg mode, type `activate .` to activate the project and then type `instantiate`.


## Instructions

The code is broken down into two parts. The first part is computationally intensive and can be expected to take 1--2 days to execute. The second part produces the plots and tables and typesets the manuscript, and is consequently much faster.

### Part 1 (intensive)

Part 1 is orchestrated by the makefile `Intensive.mk`. To run everything, simply call the shell script `sh make_intensive.sh`.

The shell script assumes the presence of 10 processor cores. Modify the relevant variables if necessary.

Part 1 output is saved in the `output` folder. This is .gitignored by default as the resulting files are large.

### Part 2

Part 2 is orchestrated by the default makefile `Makefile`. To run everything, simply type `make`. Plots will appear in `plots`, tables in `tables`, manuscript in `editedskeleton/chapters`. The typeset PDF will appear as `chapter05.pdf`. Citations may or may not work, for mysterious reasons – anyway, they will work in the overleaf project.


## A note on manuscript sources

The manuscript source is markdown, `md/henrichapter.md`. It is compiled into latex using the langsci-press template and a number of purpose-written transformations; see `Makefile` for details. Metadata such as the chapter title and abstract live in `tex` and should be modified there if necessary.


## A note on overleaf integration

To integrate this chapter in the entire book, the following files must be manually uploaded to the book overleaf project:

- `editedskeleton/chapters/05.tex`
- `editedskeleton/chapters/05-abs.tex`
- `editedskeleton/chapters/05-content.tex`
- `editedskeleton/figures/ch5` (entire folder)

Furthermore, the contents of the following files need to be copy-pasted into the corresponding files in the overleaf project:

- `editedskeleton/localbibliography.bib`
- `editedskeleton/localcommands.tex`
- `editedskeleton/localpackages.tex`

