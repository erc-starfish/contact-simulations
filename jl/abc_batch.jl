dataset = ARGS[1]
parfile = "parameters/abc_$dataset.json"


# things we need
include("abc.jl")
import Dates
import JSON
import Serialization
include("Parameterizer.jl")
import .Parameterizer
import Random


Random.seed!(123)


# data
# the Dutch arrived in the Cape in 1652, so this represents the start point
# in the simulations; for APS, the corresponding year is 1532
offset_afrikaans = 1652
offset_aps = 1532


# prepare data
data_afrikaans = CSV.read("../data/afrikaans.csv", DataFrame)
transform!(data_afrikaans, :Europeans => (x -> x) => :L1)
transform!(data_afrikaans, ["Free Blacks", "Slaves"] => ((a,b) -> a .+ b) => :L2)
data_afrikaans.offset .= offset_afrikaans

data_aps = CSV.read("../data/aps.csv", DataFrame)
transform!(data_aps, :Spanish => (x -> x) => :L1)
transform!(data_aps, [:Black, :Indigenous] => ((a,b) -> a .+ b) => :L2)
data_aps.offset .= offset_aps

if dataset == "Afrikaans"
    data = data_afrikaans
elseif dataset == "APS"
    data = data_aps
else
    throw("Undefined dataset name; valid options are 'Afrikaans' and 'APS'")
end


# read in parameters
pars = open(parfile, "r") do io
    JSON.parse(io)
end


# run ABC, also obtaining the wall-clock runtime
before = Dates.now()
results = optimize(;
                   ϵ = pars["epsilon"],
                   α = pars["alpha"],
                   nsims_max = pars["nsims_max"],
                   nparticles = pars["nparticles"],
                   parallel = true,
                   facc_min = pars["facc_min"])
after = Dates.now()
runtime = after - before
runtime_pretty = Dates.canonicalize(Dates.CompoundPeriod(runtime))


meta = Dict("dataset" => dataset,
            "epsilon" => results.ϵ,
            "facc" => results.faccs[end])


# append runtime to meta table
meta["runtime_milliseconds"] = Dates.value(runtime)
meta["runtime"] = string(runtime_pretty)
meta["launched"] = string(before)
meta["finished"] = string(after)


# and various system informations
sysinfo = Dict(
               "hostname" => gethostname(),
               "cpu_model" => string(Sys.cpu_info()[1].model),
               "CPU_NAME" => Sys.CPU_NAME,
               "CPU_THREADS" => Sys.CPU_THREADS,
               "MACHINE" => Sys.MACHINE,
               "total_memory" => trunc(Int, Sys.total_memory() / 2^20),
               "julia_version" => string(VERSION)
              )
meta["pars"] = pars
meta["sysinfo"] = sysinfo


# write results
Serialization.serialize("../output/abc_$dataset.jls", results)


# write meta
open("../meta/abc_$(dataset)_meta.json", "w") do f
    JSON.print(f, meta, 2)
end


