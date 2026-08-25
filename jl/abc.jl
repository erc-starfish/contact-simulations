# The code here assumes that the data resides in a global variable
# named 'data'. Normally, the present file should be called from
# 'abc_batch.jl'.


include("Asteroidea.jl")
include("Parameterizer.jl")
include("optimize_pars.jl")

import .Asteroidea
import .Parameterizer
using ABCdeZ
import Agents
using CSV
using DataFrames
using Distributions
using Serialization
import Statistics


# parse parameter template
meta, template = Parameterizer.parse_parameters("parameters/popdyn.json")


# distance function
function dist!(x, ve)
    pars = Dict(
                :birthrate => x[1],
                :sigma => x[2],
                :min_importtime => round(Int, x[3]),
                :importperiod => round(Int, x[4]),
                :n_seed => round(Int, x[5]),
                :weibull_shape => x[6],
                :weibull_scale => x[7],
                :carcap => round(Int, x[8]),
                :immig_shape => x[9],
                :immig_scale => x[10]
                )

    fill_template!(template, pars)

    mdf = simulate(template)

    error(mdf, data), nothing
end



# carry out simulation for a given parameter combination
function simulate(pars)
    _, mdf = Agents.paramscan(pars,
                              Asteroidea.init_model;
                              n = pars[:iter][1],
                              mdata = Asteroidea.popdyn_mdata,
                              when_model = 1,
                              parallel = false)

    mdf
end


# calculate error between simulation realization and empirical data
function error(simulation::DataFrame, empirical::DataFrame)
    # add time offset
    simulation.time .+= empirical.offset[1]

    error = 0.0

    for t in empirical.Year
        sim_L1 = convert(Float64, simulation[simulation.time .== t, :N_L1][1])
        sim_L2 = convert(Float64, simulation[simulation.time .== t, :N_L2][1])
        emp_L1 = convert(Float64, empirical[empirical.Year .== t, :L1][1])
        emp_L2 = convert(Float64, empirical[empirical.Year .== t, :L2][1])

	error += abs(sim_L1 - emp_L1) + abs(sim_L2 - emp_L2)
    end

    sumstat = error / (2 * length(empirical.Year))

    return sumstat
end


# fill parameter template with desired demographic parameters
function fill_template!(template,
        pars::Dict)
    for k in keys(pars)
        template[k] = pars[k]
    end
end


# carry out the optimization
function optimize(;
        ϵ = 0.1,
        α = 0.55,
        nsims_max = 1000,
        nparticles = 100,
        parallel = true,
        facc_min = 0.01,
        prior = OPT_PRIORS)

    # ABC
    result = abcdesmc!(prior, dist!, ϵ, nothing; α=α, nsims_max=nsims_max, nparticles=nparticles, parallel=parallel, facc_min=facc_min)

    result
end




