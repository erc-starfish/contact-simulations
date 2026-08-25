J=julia +1.11.4



.PHONY : prep clean quickstuff batch abc posterior

prep :
	mkdir tables ; \
		mkdir plots ; \
		mkdir meta ; \
		mkdir output ; \
		mkdir jl/parameters/generated

clean :
	rm -rf tables ; \
		rm -rf plots ; \
		rm -rf meta ; \
		rm -rf output ; \
		rm -rf jl/parameters/generated

quickstuff : plots/example-trajectories.pdf plots/lat.pdf plots/ts.pdf plots/experiment.pdf tables/experiment-parameters.tex meta/experiment-runtimes.txt

batch : output/$(ID).csv meta/$(ID)_meta.json

abc : output/abc_$(LANG).jls meta/abc_$(LANG)_meta.json

sample : jl/parameters/generated/optimized_$(LANG)$(ITYPE)_*.json

posterior : output/sweep_$(LANG)_abc_*.csv meta/sweep_$(LANG)_abc_*_meta.json

posterior_eternal : output/sweep_$(LANG)_eternal_abc_*.csv meta/sweep_$(LANG)_eternal_abc_*_meta.json



plots/example-trajectories.pdf : jl/Project.toml jl/Asteroidea.jl jl/example_trajectories.jl
	cd jl; $J --project=. example_trajectories.jl

plots/lat.pdf plots/ts.pdf &: jl/Project.toml jl/Asteroidea.jl jl/onerun_batch.jl jl/Parameterizer.jl output/onerun.csv
	cd jl; $J --project=. onerun_batch.jl

plots/experiment.pdf tables/experiment-parameters.tex meta/experiment-runtimes.txt &: jl/Project.toml jl/Asteroidea.jl jl/approximation_demonstration.jl
	cd jl; $J --project=. approximation_demonstration.jl

output/$(ID).csv meta/$(ID)_meta.json &: jl/Project.toml jl/batch.jl jl/Asteroidea.jl jl/Parameterizer.jl jl/parameters/$(ID).json
	cd jl; $J -p $(NPROC) --project=. batch.jl parameters/$(ID).json

output/abc_$(LANG).jls meta/abc_$(LANG)_meta.json &: jl/Project.toml jl/abc_batch.jl jl/abc.jl jl/Asteroidea.jl jl/optimize_pars.jl jl/Parameterizer.jl jl/parameters/popdyn.json jl/parameters/abc_$(LANG).json data/afrikaans.csv data/aps.csv
	cd jl; $J --project=. abc_batch.jl $(LANG)

jl/parameters/generated/optimized_$(LANG)$(ITYPE)_*.json &: jl/Project.toml output/abc_$(LANG).jls jl/parameters/generated/optimized_$(LANG)$(ITYPE)_*.json jl/prepare_after_abc.jl jl/optimize_pars.jl jl/Parameterizer.jl
	cd jl; $J --project=. prepare_after_abc.jl $(LANG) "$(ITYPE)"

output/sweep_$(LANG)_abc_*.csv meta/sweep_$(LANG)_abc_*_meta.json &: jl/Project.toml jl/abcposterior.sh jl/prepare_after_abc.jl jl/batch.jl jl/Asteroidea.jl jl/optimize_pars.jl jl/Parameterizer.jl jl/parameters/generated/optimized_$(LANG)_*.json jl/parameters/template_$(LANG)_abc.json
	cd jl; bash abcposterior.sh $(LANG) "" $(NPROC)

output/sweep_$(LANG)_eternal_abc_*.csv meta/sweep_$(LANG)_eternal_abc_*_meta.json &: jl/Project.toml jl/abcposterior.sh jl/prepare_after_abc.jl jl/batch.jl jl/Asteroidea.jl jl/optimize_pars.jl jl/Parameterizer.jl jl/parameters/generated/optimized_$(LANG)_eternal_*.json jl/parameters/template_$(LANG)_abc.json
	cd jl; bash abcposterior.sh $(LANG) "_eternal" $(NPROC)
