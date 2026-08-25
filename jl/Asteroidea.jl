module Asteroidea

using Agents
using Pipe

using Colors
using ColorSchemes
using Distributions
import Random
import StatsBase
import Statistics

export learn
export learn_nohistory
export limit_mean
export limit_var
export Beta_mm
export Beta_approximation

export starfish_yellow
export starfish_blue
export starfish_gradient
export tidepools
export raquelcol

export Speaker
export init_model
export default_mdata


# struct to hold model properties
struct ModProps
    acquire_language::Bool
    a1::Float64
    a2::Float64
    γ::Float64
    δ::Float64
    d::Float64
    aspectratio::Float64
    dim::Int
    xdim::Int
    ydim::Int
    catchment::Int
    birthrate::Float64
    sigma::Float64
    importrate::Float64
    min_importtime::Int
    importperiod::Int
    max_importtime::Int
    friend_cap::Int
    immig_distro::Gamma{Float64}
    death_distro::Weibull{Float64}
    carcap::Int
end


# brand colours
starfish_yellow = Colors.colorant"#FFBD59"
starfish_blue = Colors.colorant"#004AAD"
#starfish_gradient = Plots.cgrad(ColorScheme(range(starfish_yellow, starfish_blue, 100)))
tidepools = [
             Colors.colorant"#5dbc9b",
             Colors.colorant"#d69328",
             Colors.colorant"#f0d04f",
             Colors.colorant"#f5f9bc",
             Colors.colorant"#8f986e"
            ]

raquelcol = [
             #Colors.colorant"#FDBE85",
             Colors.colorant"#FD8D3C",
             Colors.colorant"#A63603",
             Colors.colorant"#000000"
            ]


"""
    Speaker(id, pos, P, γ, δ, class)

Composite type that represents a speaker/learner.

- `id`: agent's ID
- `pos`: agent's position in Agents.GridSpace
- `P`: weight on grammar G1
- `γ`: principal learning rate
- `δ`: secondary learning rate
- `class`: social class
- `age`: age
- `death`: time of death
"""
mutable struct Speaker <: Agents.AbstractAgent
    id::Int
    pos::NTuple{2,Int}
    P::Float64
    γ::Float64
    δ::Float64
    class::Symbol
    age::Int
    death::Float64

    # inner constructor; checks that we don't assign conceptually
    # conflicting parameter values to new speakers
    function Speaker(id, pos, P, γ, δ, class, age, death)
        if class == :L1
            age > 0 && error("Initial age of Speaker of class :L1 must be 0")
            δ > 0 && error("δ parameter of Speaker of class :L1 must be 0.0")
        end
        new(id, pos, P, γ, δ, class, age, death)
    end
end


"""
    learn(c, γ, δ, P0, n)

Simulate a 2-grammar variational learner in stationary learning environment
with penalty probabilities `c`, learning rate `γ`, secondary learning rate `δ`,
initial state `P0`, and number of learning iterations `n`.
"""
function learn(c::Vector{Float64},
        γ::Float64,
        δ::Float64,
        P0::Float64,
        n::Int)
    P = zeros(n+1)
    P[1] = P0

    for t in 2:(n+1)
        g = StatsBase.sample(1:2, StatsBase.Weights([P[t-1], 1 - P[t-1]]))
        if g == 1
            if rand() < c[1]
                P[t] = (1 - γ - δ) * P[t-1]
            else
                P[t] = (1 - γ - δ) * P[t-1] + γ
            end
        elseif g == 2
            if rand() < c[2]
                P[t] = (1 - γ - δ) * P[t-1] + γ
            else
                P[t] = (1 - γ - δ) * P[t-1]
            end
        end
    end

    P
end


"""
    learn_nohistory(c, γ, δ, P0, n)

Like `learn`, but don't collect history, only return end state.
"""
function learn_nohistory(c::Vector{Float64},
        γ::Float64,
        δ::Float64,
        P0::Float64,
        n::Int)
    P = P0

    for t in 2:(n+1)
        g = StatsBase.sample(1:2, StatsBase.Weights([P, 1 - P]))
        if g == 1
            if rand() < c[1]
                P = (1 - γ - δ) * P
            else
                P = (1 - γ - δ) * P + γ
            end
        elseif g == 2
            if rand() < c[2]
                P = (1 - γ - δ) * P + γ
            else
                P = (1 - γ - δ) * P
            end
        end
    end

    P
end


"""
    limit_mean(c, d)

Return the mean at the stationary distribution in learning environment `c`,
given L2-difficulty `d`.
"""
function limit_mean(c::Vector{Float64},
        d::Float64)
    c[2]/(sum(c) + d)
end


"""
    limit_var(c, γ, δ)

Return the variance at the stationary distribution in learning environment `c`,
given learning rates `γ` and `δ`.
"""
function limit_var(c::Vector{Float64},
        γ::Float64,
        δ::Float64)
    a = 1 - γ - δ
    C = 1 - c[1] - c[2]
    d = δ/γ

    D0 = c[2]*γ^2
    D1 = a^2 + 2*a*γ*C
    D2 = C*γ^2 + 2*a*γ*c[2]

    (D0 + D2*limit_mean(c, d))/(1 - D1) - limit_mean(c, d)^2
end


"""
    Beta_mm(μ, V)

Return the method-of-moments estimates of shape parameters for a Beta
distribution with mean `μ` and variance `V`.
"""
function Beta_mm(μ::Float64, V::Float64)
    μ * (μ*(1-μ)/V - 1), (1 - μ) * (μ*(1 - μ)/V - 1)
end


"""
    Beta_approximation(c, γ, δ)

Return a Beta distribution that approximates the stationary distribution in
learning environment `c` with learning rates `γ` and `δ`.
"""
function Beta_approximation(c::Vector{Float64}, γ::Float64, δ::Float64)
    Distributions.Beta(Beta_mm(limit_mean(c, δ/γ), limit_var(c, γ, δ))...)
end




# return a random location in "L1 space" (top half of lattice)
function random_location_L1(model)
    (rand(abmrng(model), 1:model.xdim), rand(abmrng(model), trunc(Int, model.ydim/2):model.ydim))
end


# return a random location in "L2 space" (bottom half of lattice)
function random_location_L2(model)
    (rand(abmrng(model), 1:model.xdim), rand(abmrng(model), 1:trunc(Int, model.ydim/2)))
end


# clip penalty probabilities; we cannot accept strict zero nor strict unity
# because then the Beta distribution will be undefined (cannot have all probability
# density on 0 or on 1)
function clip(x::Float64; θ = 10^-6)
    if x < θ
        return θ
    elseif x > 1 - θ
        return 1 - θ
    else
        return x
    end
end


# function to acquire one's language
function acquire!(agent::Speaker, model)
    # estimate penalty probabilities from environment. If environment should
    # be empty, we just remain in the tabula rasa state (0.5) which is assigned
    # when agents are added
    environ = collect(nearby_ids(agent, model, model.catchment))
    isempty(environ) && return

    # take a random sample from environment up to friend_cap, or use entire
    # environment if environment smaller than friend_cap
    if length(environ) > model.friend_cap
        environ = rand(abmrng(model), environ, model.friend_cap)
    end

    mP = Statistics.mean([model[id].P for id in environ])
    c = clip.([(1 - mP)*model.a2, mP*model.a1])

    # set up Beta distribution based on the above
    δ = agent.class == :L1 ? 0.0 : model.δ
    dis = Asteroidea.Beta_approximation(c, model.γ, δ)

    # set internal state
    agent.P = rand(abmrng(model), dis)
end


# add speakers to model; this is used to add both L1 and L2 speakers depending
# on the value of 'class'
function add_speakers!(model, rate::Float64, trials::Int, class::Symbol;
        acquire_language = true)
    # if rate is outside of [0,1] due to numerical inaccuracy, we clip it back
    rate = clip(rate)
    
    # how many agents to add - depends on rate and trials
    n_toadd = rand(abmrng(model), Distributions.Binomial(trials, rate))

    if class == :L1
        # we add the new agents in the neighbourhoods of randomly chosen agents
        for i in 1:n_toadd
            # pick a random agent
            rando = random_agent(model)

            # add one new agent in the random agent's local environment
            pos = random_nearby_position(rando.pos, model, model.catchment)
            newbie = add_agent!(pos, model, 0.5, model.γ, 0.0, :L1, 0, rand(abmrng(model), model.death_distro))

            # make new agent acquire their language
            acquire_language && acquire!(newbie, model)
        end
    elseif class == :L2
        # we add the new agents in random locations in the L2 half of the lattice
        for i in 1:n_toadd
            pos = random_location_L2(model)
            newbie = add_agent!(pos, model, 0.5, model.γ, model.δ, :L2, trunc(Int, rand(abmrng(model), model.immig_distro)), rand(abmrng(model), model.death_distro))

            # make new agent acquire their language
            acquire_language && acquire!(newbie, model)
        end
    else
        error("Invalid class (must be either :L1 or :L2)")
    end
end


# if input is positive, return input, if negative, return zero
function nonnegative(x::Float64)
    if x > 0
        return x
    else
        return 0
    end
end


# model stepping function
function mystep!(model)
    # birth
    #add_speakers!(model, model.birthrate, trunc(Int, sqrt(nonnegative(nagents(model)*(model.carcap - nagents(model))))), :L1)
    add_speakers!(model, model.birthrate, trunc(Int, nonnegative(nagents(model)*(1 - nagents(model)/model.carcap))), :L1; acquire_language = model.acquire_language)

    # importation (language contact) only happens if model time is between
    # min_importtime and max_importtime
    if model.min_importtime <= abmtime(model) <= model.max_importtime
        #add_speakers!(model, model.importrate, trunc(Int, sqrt(nonnegative(nagents(model)*(model.carcap - nagents(model))))), :L2)
        add_speakers!(model, model.importrate, trunc(Int, nonnegative(nagents(model)*(1 - nagents(model)/model.carcap))), :L2; acquire_language = model.acquire_language)
    end

    # death
    # increment all agents' ages and remove those for whom age > death
    for ag in collect(allagents(model))
        ag.age += 1
        if ag.age > ag.death
            remove_agent!(ag, model)
        end
    end
end


# function to initialize model
function init_model(;
        seed::Int,
        acquire_language::Bool,
        a1::Float64,
        a2::Float64,
        γ::Float64,
        d::Float64,
        aspectratio::Float64,
        dim::Int,
        catchment::Int,
        birthrate::Float64,
        sigma::Float64,
        min_importtime::Int,
        importperiod::Int,
        immig_shape::Float64,
        immig_scale::Float64,
        friend_cap::Int,
        n_seed::Int,
        weibull_shape::Float64,
        weibull_scale::Float64,
        carcap::Int,
        iter::Int,
        when::Int)
    # set up a grid space
    lattice_x = trunc(Int, sqrt(aspectratio * dim))
    lattice_y = trunc(Int, sqrt(dim / aspectratio))
    dims = (lattice_x, lattice_y)
    space = GridSpace(dims, periodic = false)

    props = ModProps(
                     acquire_language,
                     a1,
                     a2,
                     γ,
                     γ * d,
                     d,
                     aspectratio,
                     dim,
                     lattice_x,
                     lattice_y,
                     catchment,
                     birthrate,
                     sigma,
                     (sigma/(1 - sigma))*birthrate,
                     min_importtime,
                     importperiod,
                     min_importtime + importperiod,
                     friend_cap,
		     Distributions.Gamma(immig_shape, immig_scale),
                     Distributions.Weibull(weibull_shape, weibull_scale),
                     carcap)

    # set up model
    model = StandardABM(Asteroidea.Speaker, 
                        space; 
                        properties = props,
                        model_step! = mystep!,
                        rng = Random.Xoshiro(seed))

    # add "seed" agents
    for i in 1:n_seed
        add_agent!(random_location_L1(model), model, 1.0, model.γ, 0.0, :L1, 0, rand(abmrng(model), model.death_distro))
    end

    return model
end


# data collecting functions
popsize(model) = nagents(model)

prop_L2(model) = sum([ag.class == :L2 for ag in allagents(model)]) / nagents(model)

mean_P(model) = Statistics.mean([ag.P for ag in allagents(model)])

default_mdata = [popsize, prop_L2, mean_P]

N_L1(model) = sum([ag.class == :L1 for ag in allagents(model)])
N_L2(model) = sum([ag.class == :L2 for ag in allagents(model)])

popdyn_mdata = [popsize, N_L1, N_L2]



end
