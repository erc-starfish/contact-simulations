#=
# Simulate variational learners and demonstrate that the Beta approximation
# works well across a range of model parameter values.
=#


include("Asteroidea.jl")

using .Asteroidea
using BenchmarkTools
using Colors
using DataFrames
using Distributions
using LaTeXTabulars
using Pipe
using CairoMakie
using Random
using Statistics


# destination for outputs
dest = "../tables"
destmeta = "../meta"

# set RNG seed
Random.seed!(12345)

# number of experiments
nE = 6

# sample some random parameter values
c1 = @pipe rand(nE) |> round.(_; digits=2)
c2 = @pipe rand(nE) |> round.(_; digits=2)
γ = @pipe 0.1 .* rand(nE) |> round.(_; digits=3)
δ = @pipe 0.1 .* rand(nE) |> round.(_; digits=3)

# wrapper function to simulate a number of learners and obtain the final states
function learn_many(c::Vector{Float64}, γ::Float64, δ::Float64, P0::Float64, n::Int, nL::Int)
    [learn_nohistory(c, γ, δ, P0, n) for i in 1:nL]
end

# simulate learners and get approximating Beta distributions
nL = 10_000 # number of learners
args = 0.0:0.0001:1.0 # pdf is calculated over these values
learners = []
appros = []
for k in 1:nE
    @pipe learn_many([c1[k], c2[k]], γ[k], δ[k], 0.5, 10_000, nL) |> push!(learners, _)
    @pipe Beta_approximation([c1[k], c2[k]], γ[k], δ[k]) |> Distributions.pdf(_, args) |> push!(appros, _)
end

# make individual plot facets
f = Figure(size=(600, 750))
titles = ["(a)", "(b)", "(c)", "(d)", "(e)", "(f)"]

effs = [f[1,1], f[1,2], f[2,1], f[2,2], f[3,1], f[3,2]]

for k in 1:nE
    # main facet plot
    ax = Axis(effs[k], title=titles[k], limits=(extrema(learners[k]) .+ (-0.1, 0.5) .* Statistics.mean(learners[k]), (0, 1.2 * maximum(appros[k]))), xgridvisible = true, ygridvisible = true, titlealign=:left)
    CairoMakie.hist!(ax, learners[k], normalization=:pdf, color=Asteroidea.starfish_yellow, strokecolor=:black, strokewidth=1.0, bins=20)
    CairoMakie.lines!(ax, args, appros[k], color=Asteroidea.starfish_blue, linewidth=3.0)

    # inset
    ax_inset = Axis(effs[k],
    width=Relative(0.28),
    height=Relative(0.25),
    halign=0.95,
    valign=0.95,
    limits=((0.0, 1.0), (0.0, 1.2 * maximum(appros[k]))), 
    xgridvisible = false, 
    ygridvisible = false,
   xticks = [0.0, 1.0])

    CairoMakie.hist!(ax_inset, learners[k], normalization=:pdf, color=Asteroidea.starfish_yellow, strokecolor=:black, strokewidth=0.5, bins=20)
    CairoMakie.lines!(ax_inset, args, appros[k], color=Asteroidea.starfish_blue, linewidth=1.2)
    CairoMakie.hideydecorations!(ax_inset)

    CairoMakie.translate!(ax_inset.blockscene, 0, 0, 150)

    #=
    # construct reasonable x-axis ticks
    xm, xM = extrema(learners[k])
    xr = xM - xm
    xt = LinRange(xm + 0.1*xr, xM - 0.1*xr, 3)

    hg = histogram(learners[k]; normalize=:pdf, title=titles[k], titlelocation=:left, label=false, c=starfish_yellow, xticks=(xt, round.(xt; digits=3)))
    plot!(args, appros[k], c=starfish_blue, lw=3.0, label=false)
    xlims!(extrema(learners[k])...)
    ylims!(0, 1.4 * maximum(appros[k]))
    push!(facets, hg)
    =#
end

# combine facets into final plot
save("../plots/experiment.pdf", f)

# write out the parameter values
df = DataFrame(experiment=titles, c1=c1, c2=c2, gamma=γ, delta=δ)
#latex_tabular("$dest/experiment-parameters.tex", Tabular("lrrrr"), eachrow(df))

open("$dest/experiment-parameters.tex", "w") do f
    println(f, "\\begin{table}")
    println(f, "\\caption{Model parameters (\$c_1\$, \$c_2\$, \$\\gamma\$ and \$\\delta\$; randomly drawn) for the simulation experiments of Figure \\ref{fig:experiment}, together with the mean (\$\\E[W_1]\$) and variance (\$\\textnormal{Var}[W_1]\$) of the stationary distribution (\\ref{eq:mu}--\\ref{eq:sigma}) and the moment-matched shape parameters (\$\\alpha\$, \$\\beta\$) of the approximating Beta distribution.}\\label{tbl:experiment}")
    println(f, "\\begin{tabular}{lrrrrrrrr}")
    println(f, "\\toprule")
    println(f, " & \$c_1\$ & \$c_2\$ & \$\\gamma\$ & \$\\delta\$ & \$\\textnormal{E}[W_1]\$ & \$\\textnormal{Var}[W_1]\$ & \$\\alpha\$ & \$\\beta\$ \\\\")
    println(f, "\\midrule")
    for r in eachrow(df)
        EP = Asteroidea.limit_mean([r[:c1], r[:c2]], r[:delta]/r[:gamma])
        VP = Asteroidea.limit_var([r[:c1], r[:c2]], r[:gamma], r[:delta])
        alpha, beta = Asteroidea.Beta_mm(EP, VP)

        EP = round(EP; digits=2)
        VP = round(VP; digits=4)
        alpha = round(alpha; digits=1)
        beta = round(beta; digits=1)

        print(f, join(string.(collect(r)), " & "))
        print(f, " & ")
        print(f, join(string.([EP, VP, alpha, beta]), " & "))
        print(f, " \\\\")
        println(f)
    end
    println(f, "\\bottomrule")
    println(f, "\\end{tabular}")
    println(f, "\\end{table}")
end

# runtimes
open("$destmeta/experiment-runtimes.txt", "w") do file
    write(file, "learning simulation:\n\n")
    show(file, "text/plain", @benchmark learn_nohistory([c1[1], c2[1]], γ[1], δ[1], 0.5, 10_000))
    write(file, "\n\n\n\nsampling from Beta:\n\n")
    show(file, "text/plain", @benchmark rand(Beta_approximation([c1[1], c2[1]], γ[1], δ[1])))
end

