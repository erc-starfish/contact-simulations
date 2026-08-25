include("Parameterizer.jl")
import .Parameterizer
import JSON
import Random
import Serialization
import Distributions

include("optimize_pars.jl")


Random.seed!(123)


nrep = 10

dataset = ARGS[1]
itype = ARGS[2]

for rep in 1:nrep

	abcfile = "../output/abc_$dataset.jls"
	templatefile = "parameters/template_$(dataset)_abc.json"
	outfile = "parameters/generated/optimized_$(dataset)$(itype)_$(rep).json"


	ar = Serialization.deserialize(abcfile)

	pars = Dict("birthrate" =>          rand([t[1] for t in ar.P[ar.Wns .> 0.0]]),
		    "sigma" =>              rand([t[2] for t in ar.P[ar.Wns .> 0.0]]),
		    "min_importtime" =>     rand([t[3] for t in ar.P[ar.Wns .> 0.0]]),
		    "importperiod" =>       rand([t[4] for t in ar.P[ar.Wns .> 0.0]]),
		    "n_seed" =>             rand([t[5] for t in ar.P[ar.Wns .> 0.0]]),
		    "weibull_shape" =>      rand([t[6] for t in ar.P[ar.Wns .> 0.0]]),
		    "weibull_scale" =>      rand([t[7] for t in ar.P[ar.Wns .> 0.0]]),
		    "carcap" =>             rand([t[8] for t in ar.P[ar.Wns .> 0.0]]),
		    "immig_shape" =>        rand([t[9] for t in ar.P[ar.Wns .> 0.0]]),
		    "immig_scale" =>        rand([t[10] for t in ar.P[ar.Wns .> 0.0]]))

	if itype == "_eternal"
		pars["importperiod"] = rand(Distributions.DiscreteUniform(OPT_LBS[:importperiod], OPT_UBS[:importperiod]))
	end


	# parameter "template"
	template = open(templatefile, "r") do f
		JSON.parse(f)["parameters"]
	end


	# meta
	meta = open(templatefile, "r") do f
		JSON.parse(f)["meta"]
	end


	# define output and meta files
	meta["outfile"] = "../output/sweep_$(dataset)$(itype)_abc_$(rep).csv"
	meta["metafile"] = "../meta/sweep_$(dataset)$(itype)_abc_$(rep)_meta.json"


	# substitute optimized demographic parameter values
	for k in keys(pars)
		template[k]["val"] = pars[k]
	end


	# write out
	towrite = Dict(
		       "meta" => meta,
		       "parameters" => template
		       )

	open(outfile, "w") do f
		JSON.print(f, towrite, 2)
	end

end


