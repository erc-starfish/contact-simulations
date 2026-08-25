include("Asteroidea.jl")

import .Asteroidea
using CairoMakie
using Random

Random.seed!(123)


c = [0.05, 0.4]
γ = [0.01, 0.05, 0.1]
d = 0.05

f = Figure(size=(575, 700))

ylab = rich(rich("W", font=:italic), subscript("1"), " (weight on ", rich("G", font=:italic), subscript("1"), ")")
xlab = ["", "", "time"]


function mean_evolution(c, γ, δ, P0, iter)
    P = zeros(iter + 1)
    P[1] = P0

    C1 = (1 - c[1] - c[2])*γ - γ + 1 - δ

    for n in 2:(iter + 1)
        P[n] = C1^n * P0 + (1 - C1^n) * ((γ * c[2])/(1 - C1))
    end

    P
end

prefix = ["a", "b", "c"]

for i in 1:3
    δ = γ[i] * d
    iter = trunc(Int, 50 * γ[i]^-1)
    P0 = 0.1

    history = Asteroidea.learn(c, γ[i], δ, P0, iter)
    meanevo = mean_evolution(c, γ[i], δ, P0, iter)

    title = "($(prefix[i])) Learning rate γ = $(γ[i])"
    limits = (nothing, (0.0, 1.0))

    Axis(f[i,1], limits=limits, ylabel=ylab, xlabel=xlab[i], title=title, yticks = 0.0:0.2:1.0, xticks=range(0, iter, 6), titlealign=:left)

    CairoMakie.lines!(1:(iter+1), meanevo, color=Asteroidea.starfish_yellow, linewidth=3.0)
    CairoMakie.lines!(1:(iter+1), history, color=Asteroidea.starfish_blue)
end

save("../plots/example-trajectories.pdf", f)


