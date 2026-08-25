using CSV, DataFrames
using CairoMakie
using Statistics

global_colormap = :jet1


function bifuheatmap(df;
        climits = (0,1))
    props = range(0.1, 0.8, 29)

    roundtonearest(p) = props[findmin((p .- props) .^ 2)[2]]

    transform!(df, :prop_L2 => (p -> roundtonearest.(p)) => :prop_L2)
    #transform!(df, :d => (p -> roundtonearest.(p)) => :d)

    orig = copy(df)

    df = df[df.time .== maximum(df.time), :]

    df = combine(groupby(df, [:d, :prop_L2]), :mean_P => Statistics.mean)

    df = unstack(df, :d, :mean_P_mean)

    df = df[:, Not(:prop_L2)]

    df = Matrix(df)

    df = transpose(df)

    a1 = unique(orig.a1)[1]
    a2 = unique(orig.a2)[1]
    ds = range(minimum(orig.d), maximum(orig.d), 1000)
    sigmacrit = [(1.0 - a2/a1)*(1.0 + a2/d) for d in ds]

    f = Figure(size = (550, 610))
    #figure_padding = (10, 30, 10, 10))
    #

    limits = (extrema(orig.d), extrema(orig.prop_L2))
    #limits = ((0.1, 0.8), (0.1, 0.8))

    ax = Axis(f[2,1], xticks=range(0.1, 0.9, 9), yticks=range(0.1, 0.9, 9),
              xlabel = rich(rich("d", font=:italic), " (L2-difficulty)"),
              ylabel = rich("σ (proportion of L2 learners)"),
              limits = limits)

    CairoMakie.heatmap!(ax, unique(orig.d), unique(orig.prop_L2), df, colormap=global_colormap, colorrange=climits)#, colormap=Asteroidea.starfish_gradient)
    CairoMakie.lines!(ax, ds, sigmacrit, color=:white, linewidth=3.0, linestyle=:dash)

    CairoMakie.contour!(ax, unique(orig.d), unique(orig.prop_L2), df, labels=true, color=:white, levels=[0.01, 0.1, 0.25, 0.5, 0.75], labelsize=16, linewidth=2.0)#, labelfont=:bold)

    #CairoMakie.poly!(ax, Point2f[(0.81, 0.72), (1.0, 0.72), (1.0, 1.0), (0.81, 1.0)], color=:white, space=:relative, alpha=0.9)

    #CairoMakie.Colorbar(f, bbox=ax.scene.viewport, alignmode = Outside(10), halign = :right, valign = :top, limits=climits, colormap=global_colormap, vertical=true, label=rich("weight on ", rich("G", font=:italic), subscript("1")), width=10, height=100, labelvisible=true, flip_vertical_label=false, flipaxis=false)
    
    CairoMakie.Colorbar(f[1,1], limits=climits, colormap=global_colormap, vertical=false, label=rich("weight on ", rich("G", font=:italic), subscript("1")), width=100, height=10, labelvisible=true)#, flip_vertical_label=false, flipaxis=false)

    colsize!(f.layout, 1, Relative(1))

    f, df
end


df = CSV.read("../output/bifurcation_long.csv", DataFrame)
fig, figdf = bifuheatmap(df)
save("../plots/bifu.pdf", fig)


