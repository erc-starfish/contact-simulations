using CSV, DataFrames
using CairoMakie
using Statistics

global_colormap = :jet1


offset_afrikaans = 1652


function afriheatmap(df;
        climits = (0,1))
    orig = copy(df)

    df.time .+= offset_afrikaans

    df = df[df.time .== maximum(df.time), :]

    df = combine(groupby(df, [:d, :aspectratio]), :mean_P => Statistics.mean)

    df = unstack(df, :d, :mean_P_mean)

    df = df[:, Not(:aspectratio)]

    df = Matrix(df)

    df = transpose(df)

    f = Figure(size = (550, 550))
    #figure_padding = (10, 30, 10, 10))
    #

    #limits = (extrema(orig.d), (0.1, 0.9))
    #

    xlen = length(unique(orig.d))
    ylen = length(unique(orig.aspectratio))

    ax = Axis(f[1,1],
              xscale = log10,
              yscale = log10,
              #xticks = (1:xlen, string.(round.(unique(orig.d); digits=3))),
              #yticks = (1:ylen, string.(round.(unique(orig.aspectratio); digits=3))),
              xlabel = rich("L2-difficulty ", rich("d", font=:italic)),
              ylabel = rich("Lattice aspect ratio ρ"))
    #=
    #, xticks=range(0.1, 0.9, 9), yticks=range(0.1, 0.9, 9),
              xlabel = rich(rich("d", font=:italic), " (L2-difficulty)"),
              ylabel = rich("σ (proportion of L2 learners)"),
              limits = limits)
              =#

    #CairoMakie.heatmap!(ax, 1:xlen, 1:ylen, df, colormap=global_colormap, colorrange=climits)#, colormap=Asteroidea.starfish_gradient)
    CairoMakie.heatmap!(ax, unique(orig.d), unique(orig.aspectratio), df, colormap=global_colormap, colorrange=climits)#, colormap=Asteroidea.starfish_gradient)

    #CairoMakie.contour!(ax, unique(orig.d), unique(orig.aspectratio), df, labels=true, color=:white, levels=[0.05, 0.1, 0.25, 0.5], labelsize=16, linewidth=2.0)

    CairoMakie.poly!(ax, Point2f[(0.83, 0.74), (1.0, 0.74), (1.0, 1.0), (0.83, 1.0)], color=:white, space=:relative, alpha=0.9)
    CairoMakie.Colorbar(f, bbox=ax.scene.viewport, alignmode=Outside(10), halign=:right, valign=:top, limits=climits, colormap=global_colormap, vertical=true, label=rich("weight on ", rich("G", font=:italic), subscript("1")), width=10, height=100, labelvisible=true, flipaxis=false, flip_vertical_label=false)

    colsize!(f.layout, 1, Relative(1))

    f
end


df = CSV.read("../output/sweep_Afrikaans_eternal_large.csv", DataFrame)
fig = afriheatmap(df)
save("../plots/afrikaans-eternal.pdf", fig)


