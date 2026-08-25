using CSV, DataFrames
using CairoMakie
using Statistics

#global_colormap = Reverse(:batlow)
global_colormap = :jet1


function latshapeheatmap(df,
        variable::Symbol;
        climits = (0,1))
    df = combine(groupby(df, [:time, :aspectratio, :importperiod]), variable => Statistics.mean)

    plots = []

    f = Figure(size = (600, 720),
               figure_padding = (10, 30, 10, 10))

    itimes = unique(df.importperiod)
    Tmig = itimes

    lims = ((0, 3000), (10^-3, 0.4 * 10^4))

    title_prefixes = ["(a)", "(b)", "(c)", "(d)", "(e)", "(f)"]

    titles = []

    for i in 1:6
        push!(titles, rich("$(title_prefixes[i]) ", rich("T", font=:bold_italic), subscript("L2"), " = ", string(Tmig[i]), fontsize=13))
    end

    ylab = rich("aspect ratio ρ")

    axes = [
            Axis(f[2,1], yscale=log10, xgridvisible = false, ylabel=ylab, title=titles[1], limits=lims, titlealign=:left),
            Axis(f[2,2], yscale=log10, xgridvisible = false, title=titles[2], limits=lims, titlealign=:left),
            Axis(f[3,1], yscale=log10, xgridvisible = false, ylabel=ylab, title=titles[3], limits=lims, titlealign=:left),
            Axis(f[3,2], yscale=log10, xgridvisible = false, title=titles[4], limits=lims, titlealign=:left),
            Axis(f[4,1], yscale=log10, xgridvisible = false, xlabel="time (years)", ylabel=ylab, title=titles[5], limits=lims, titlealign=:left),
            Axis(f[4,2], yscale=log10, xgridvisible = false, xlabel="time (years)", title=titles[6], limits=lims, titlealign=:left)
           ]

    for i in 1:6
        CairoMakie.linesegments!(axes[i], [50, itimes[i] + 50], 0.4 * 10^4 .* ones(2), linewidth=25, color=:orange)
        CairoMakie.heatmap!(axes[i], unique(df.time), unique(df.aspectratio), getmatrix(df, itimes[i], Symbol(variable, "_mean")), colormap=global_colormap, colorrange=climits)#, colormap=Asteroidea.starfish_gradient)
        CairoMakie.linesegments!(axes[i], [minimum(df.time) - 250, maximum(df.time) + 250], 0.12*10^4 .* ones(2), linewidth=0.9, color=:black)
    end

    CairoMakie.Colorbar(f[1,2], limits = climits, colormap=global_colormap, vertical=false, label=rich("weight on ", rich("G", font=:italic), subscript("1")), width=100, labelvisible=true)

    colsize!(f.layout, 1, Relative(1/2))
    colsize!(f.layout, 2, Relative(1/2))

    f
end


function getmatrix(df, Tmig, variable::Symbol)
    dfhere = df[df.importperiod .== Tmig, :]
    dfhere = dfhere[:, Not(:importperiod)]
    dfhere = unstack(dfhere, :time, variable)
    dfhere = dfhere[:, Not(:aspectratio)]
    dfhere = Matrix(dfhere)
    transpose(dfhere)
end


df = CSV.read("../output/latshape.csv", DataFrame)
fig = latshapeheatmap(df, :mean_P)
save("../plots/latshape.pdf", fig)


