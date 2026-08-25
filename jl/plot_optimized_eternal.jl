using CairoMakie
using ColorSchemes
using CSV
using DataFrames

nrep = 10

include("Asteroidea.jl")
using .Asteroidea

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


# plot mean_P
function plot_optimized(ax,
        df::DataFrame,
        offset::Int;
        maxtime::Int = 2025)
    transform!(df, :time => (x -> x .+ offset) => :time)

    subset!(df, :time => (x -> x .<= maxtime))

    for d in unique(df.d)
        df_here = subset(df, :d => (x -> x .== d))
        for rep in unique(df_here.seed)
            df_herehere = subset(df_here, :seed => (x -> x .== rep))
            lines!(ax, df_herehere.time, df_herehere.mean_P, alpha=0.1, color=d, colorrange=(0.1, 100.0), colormap=cgrad(:darkrainbow, [0.1, 1.0, 100.0] ./ 100.0, categorical = true), label=string(round(d; digits=1)))
        end
    end
end


# plot population
function plot_population(ax,
        df::DataFrame,
        df_empirical::DataFrame,
        offset::Int;
        maxtime::Int = 2025)
    transform!(df, :time => (x -> x .+ offset) => :time)

    subset!(df, :time => (x -> x .<= maxtime))

    for d in unique(df.d)
        df_here = subset(df, :d => (x -> x .== d))
    for rep in unique(df.seed)
        dfh = subset(df_here, :seed => (x -> x .== rep))
        lines!(ax, dfh.time, (1 .- dfh.prop_L2) .* dfh.popsize, label="L1", alpha=0.05, color=starfish_blue)
        lines!(ax, dfh.time, dfh.prop_L2 .* dfh.popsize, label="L2", alpha=0.05, color=:red)
    end
end

    scatter!(ax, df_empirical.Year, df_empirical.L1, marker=:cross, strokewidth=1, strokecolor=:white, markersize=16, color=starfish_blue, alpha=0.8)
    scatter!(ax, df_empirical.Year, df_empirical.L2, marker=:xcross, strokewidth=1, strokecolor=:white, markersize=16, color=:red, alpha=0.8)
end


# prepare figure and axes for population plot
function prep_popplot()
    fig = Figure(size = (600, 700))

    ax_Afri = Axis(fig[2,1],
                   limits = (nothing, (-3000, 76_000)),
                   xlabel = "year",
                   ylabel = "number of speakers (thousands)",
                   yticks = 1000 .* [0, 20, 40, 60],
                   ytickformat = labels -> ["$(round(Int, label / 1000.0))" for label in labels],
                   title = "(b) Afrikaans",
                   titlealign = :left)
    ax_APS = Axis(fig[1,1],
                  limits = (nothing, (-1000, 17_000)),
                  xlabel = "year",
                  ylabel = "number of speakers (thousands)",
                  yticks = 1000 .* [0, 5, 10, 15, 20],
                  ytickformat = labels -> ["$(round(Int, label / 1000.0))" for label in labels],
                  title = "(a) Afro-Peruvian Spanish",
                  titlealign = :left)

    return fig, ax_Afri, ax_APS
end


# prepare figure and axes for optimized plot
function prep_optiplot()
    fig = Figure(size = (600, 400))
    ax_Afri = Axis(fig[1,1], 
                   limits=(nothing, (-0.05, 1.05)),
                   xticks=1700:100:2000,
                   yticks=0.0:0.2:1.0,
                   #title="(b) Afrikaans",
                   titlealign=:left,
                   xlabel = "year",
                   ylabel = rich("mean weight on ", rich("G", font=:italic), subscript("1")))

    #=
    ax_APS = Axis(fig[1,1], 
                  limits=(nothing, (-0.05, 1.05)),
                  xticks=1600:100:2000,
                  yticks=0.0:0.2:1.0,
                  title="(a) Afro-Peruvian Spanish",
                  titlealign=:left,
                  xlabel = "year",
                  ylabel = rich("mean weight on ", rich("G", font=:italic), subscript("1")))
                  =#

    return fig, ax_Afri#, ax_APS
end





# ABC fits
fig, ax_Afri = prep_optiplot()

for rep in 1:nrep

# Simulations with optimized parameters
df_Afri = CSV.read("../output/sweep_Afrikaans_eternal_abc_$rep.csv", DataFrame)
#df_APS = CSV.read("../output/sweep_APS_abc_$rep.csv", DataFrame)

#subset!(df_Afri, [:d, :aspectratio] => ((a,b) -> b .== 1.0))
##subset!(df_Afri, [:d, :aspectratio] => ((a,b) -> b .== 0.01))
#subset!(df_APS, [:d, :aspectratio] => ((a,b) -> b .== 1.0))

# only interested in plotting these L2-difficulties
#admissibles = [0.1, 1.0, 100.0]

#subset!(df_Afri, [:d, :aspectratio] => ((a,b) -> round.(a; digits=1) .∈ [admissibles] .&& 1.0 .<= b .<= 2.0))
#subset!(df_APS, [:d, :aspectratio] => ((a,b) -> round.(a; digits=1) .∈ [admissibles] .&& 1.0 .<= b .<= 2.0))

Afri_L2_start = (offset_afrikaans .+ unique(df_Afri.min_importtime))[1]
Afri_L2_end = (Afri_L2_start .+ unique(df_Afri.importperiod))[1]

#APS_L2_start = (offset_aps .+ unique(df_APS.min_importtime))[1]
#APS_L2_end = (APS_L2_start .+ unique(df_APS.importperiod))[1]


xlims!(ax_Afri, minimum(df_Afri.time) + offset_afrikaans - 10, 2025 + 10)
#xlims!(ax_APS, minimum(df_APS.time) + offset_aps - 10, 2025 + 10)

plot_optimized(ax_Afri, df_Afri, offset_afrikaans; maxtime = 2025)
#plot_optimized(ax_APS, df_APS, offset_aps; maxtime = 2025)

#poly!(ax_Afri, Point2f[(Afri_L2_start, -1), (Afri_L2_start, 8), (Afri_L2_end, 8), (Afri_L2_end, -1)], alpha=0.1, color=:orange)
#poly!(ax_APS, Point2f[(APS_L2_start, -1), (APS_L2_start, 8), (APS_L2_end, 8), (APS_L2_end, -1)], alpha=0.1, color=:orange)

#axislegend(ax_Afri, rich("L2-difficulty ", rich("d", font=:italic)), position = (0.95, 0.9))

end

    axislegend(ax_Afri, "L2-difficulty", merge=true, position = (0.98, 0.96))


save("../plots/optimized-simulations-eternal.pdf", fig)

