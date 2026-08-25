# parameters are read from this file, supplied as a command-line argument
parfile = ARGS[1]


# things we need
using Distributed

@everywhere begin
    include("Asteroidea.jl")
    import .Asteroidea
    using Agents
end

import CSV
import DataFrames
import Dates
import JSON

include("Parameterizer.jl")
import .Parameterizer


# this function carries out the simulation(s)
@everywhere function sweep(parameters)
    # if "when" is a single value, paramscan outputs every when'th iteration.
    # if it is a vector, it outputs at every time specified in that vector
    when = length(parameters[:when]) == 1 ? parameters[:when][1] : parameters[:when]

    _, mdf = paramscan(parameters,
                       Asteroidea.init_model;
                       n = parameters[:iter][1],
                       mdata = Asteroidea.default_mdata,
                       when_model = when,
                       parallel = true)

    mdf
end


# parse parameters
meta, pars = Parameterizer.parse_parameters(parfile)


# run simulation(s), also obtaining the wall-clock runtime
before = Dates.now()
results = sweep(pars)
after = Dates.now()
runtime = after - before
runtime_pretty = Dates.canonicalize(Dates.CompoundPeriod(runtime))


# append runtime to meta table
meta["runtime_milliseconds"] = Dates.value(runtime)
meta["runtime"] = string(runtime_pretty)
meta["launched"] = string(before)
meta["finished"] = string(after)


# and append name of parameter file, too
meta["parfile"] = parfile


# and append number of worker processes
meta["nworkers"] = nworkers()


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
meta["sysinfo"] = sysinfo


# write results
CSV.write(meta["outfile"], results)


# write meta
open(meta["metafile"], "w") do f
    JSON.print(f, meta, 2)
end


