using DataFrames
import JSON

include("latextabler.jl")
include("optimize_pars.jl")


# master list of parameters
mlist = open("parameters/list_of_parameters.json", "r") do f
    JSON.parse(f)
end

# optimized parameter values: Afrikaans
#opti_afrikaans = open("../meta/popdyn_Afrikaans_transient.json", "r") do f
#    JSON.parse(f)
#end

# optimized parameter values: APS
#opti_aps = open("../meta/popdyn_APS_transient.json", "r") do f
#    JSON.parse(f)
#end

deforder = mlist["meta"]["default_order"]
push!(deforder, "min_importtime")
pars = mlist["parameters"]


# parameters we wish to print
toprint = ["birthrate", "sigma", "min_importtime", "importperiod", "n_seed", "weibull_shape", "weibull_scale", "carcap", "immig_shape", "immig_scale"]


# make a dataframe
pars_toprint = []
descriptions_toprint = []
#afri_toprint = []
#aps_toprint = []
toprint_inorder = []
for par in deforder
    if par ∈ toprint
        push!(toprint_inorder, par)
        push!(pars_toprint, mlist["parameters"][par]["symbol"])
        push!(descriptions_toprint, mlist["parameters"][par]["description"])
        if par ∈ ["min_importtime", "carcap", "importperiod", "n_seed"]
            #push!(afri_toprint, opti_afrikaans["parameters"][par])
        #push!(aps_toprint, opti_aps["parameters"][par])
              else
        #push!(afri_toprint, round(opti_afrikaans["parameters"][par], digits=2))
        #push!(aps_toprint, round(opti_aps["parameters"][par], digits=2))
    end
    end
end

df_orig = DataFrame(Parameter=descriptions_toprint, symbol=pars_toprint, first=Symbol.(toprint_inorder))

df_lbs = DataFrame(Symbol(k) => v for (k, v) in pairs(OPT_LBS))
df_ubs = DataFrame(Symbol(k) => v for (k, v) in pairs(OPT_UBS))
df_names = DataFrame(Symbol(k) => "\$$v\$" for (k, v) in pairs(OPT_PRIORNAMES))

rename!(df_lbs, :second => :lbs)
rename!(df_ubs, :second => :ubs)
rename!(df_names, :second => :names)

df = leftjoin(df_orig, df_lbs, on=:first)
df = leftjoin(df, df_ubs, on=:first)
df = leftjoin(df, df_names, on=:first)


MYORDER = [:birthrate, :sigma, :importperiod, :immig_shape, :immig_scale, :n_seed, :weibull_shape, :weibull_scale, :carcap, :min_importtime]
orderdict = Dict(x => i for (i,x) in enumerate(MYORDER))

df = sort(df, order(:first, by = x -> orderdict[x]))

#df = df[:, [:Parameter, :symbol, :lbs, :ubs]]
df = df[:, [:Parameter, :symbol, :names]]

# pretty-print
open("../tables/optimize-bounds.tex", "w") do f
    latextabler(f, df; alignment = "lcl", header = ["Parameter", "Symbol", "Prior"], caption = "Prior distributions of model parameters for ABC-SMC. `TrNormal' refers to a normal distribution truncated to the interval specified.", label = "tbl:optimizebounds")
end


