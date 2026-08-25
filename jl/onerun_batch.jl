# include custom code
include("Parameterizer.jl")
include("Asteroidea.jl")
import .Parameterizer
import .Asteroidea

# load packages
using Agents
using CSV
using DataFrames
using CairoMakie
using Colors
using ColorSchemes
using Distributions


#mycols = ColorScheme(get(ColorSchemes.okabe_ito, range(0.0, 0.4, length=3)))
mycols = reverse(Asteroidea.raquelcol)

   
time_increments = [20, 40, 40, 100, 100, 100]


function plot_onerun(df)
    f = Figure(size=(600, 450))

    ax = Axis(f[1,1], xlabel="time (years)", xticks=range(0, 500, 6), yticks=range(0.0, 1.0, 6),
	      xgridvisible=false)

    meanP = lines!(df.time, df.mean_P, color=mycols[1])
    propL2 = lines!(df.time, df.prop_L2, color=mycols[2])
    popsiz = lines!(df.time, df.popsize ./ maximum(df.popsize), color=mycols[3])

    Legend(f[1,1], [meanP, propL2, popsiz], [rich("mean weight on ", rich("G", font=:italic), subscript("1")), "proportion of L2 learners", "normalized population size"], tellheight=false, tellwidth=false, halign=:right, margin=(5, 5, 5, 150))

    #time_increments = [100, 700, 800, 1400, 2000, 5000]

    for snap in cumsum(time_increments)
        linesegments!([snap, snap], [0.0, 1.3], color=:black, linestyle=:dash, linewidth=1.0, alpha=0.7)
        text!(snap - 3, 1.3, text=rich(rich("t", font=:italic), " = ", string(snap)), rotation=π/2, align=(:right, :baseline), fontsize=12)
    end

    f
end


function illustrate_onerun_on_lattice(filename)
    meta, pars = Parameterizer.parse_parameters(filename)

    mod = Asteroidea.init_model(;
                                seed = 1,
                                a1 = pars[:a1][1],
                                a2 = pars[:a2][1],
                                γ = pars[:γ][1],
                                d = pars[:d][1],
                                aspectratio = pars[:aspectratio][1],
                                dim = pars[:dim][1],
                                catchment = pars[:catchment][1],
                                birthrate = pars[:birthrate][1],
                                sigma = pars[:sigma][1],
                                min_importtime = pars[:min_importtime][1],
                                importperiod = pars[:importperiod][1],
                                immig_shape = pars[:immig_shape][1],
                                immig_scale = pars[:immig_shape][1],
                                friend_cap = pars[:friend_cap][1],
                                n_seed = pars[:n_seed][1],
                                weibull_shape = pars[:weibull_shape][1],
                                weibull_scale = pars[:weibull_scale][1],
                                carcap = pars[:carcap][1],
                                acquire_language = pars[:acquire_language][1],
                                iter = pars[:iter][1],
                                when = pars[:when][1])

    xdim = mod.xdim
    ydim = mod.ydim

    colormap_resolution = 100
    #cm = colormap("RdBu", colormap_resolution + 1)
    #cm = ColorScheme(get(ColorSchemes.brg, range(0.0, 1.0, length=colormap_resolution+1)))
    #cm = ColorScheme(range(Asteroidea.starfish_yellow, Asteroidea.starfish_blue, length = colormap_resolution + 1))

    #cm = reverse(get(ColorSchemes.batlow, range(0.0, 1.0, length = colormap_resolution + 1)))
    cm = get(ColorSchemes.jet1, range(0.0, 1.0, length = colormap_resolution + 1))

    agent_color(a) = cm[trunc(Int, a.P*100) + 1]
    agent_marker(a) = a.class == :L1 ? :cross : :xcross
    #agent_marker(a) = a.class == :L1 ? :utriangle : :dtriangle

    agent_size(a) = rand(abmrng(mod)) < 0.01 ? 13.0 : 0.0

    function offset_fun(a)
        sd = 0.5
        xoff = rand(Distributions.Normal(0.0, sd))
        yoff = rand(Distributions.Normal(0.0, sd))

        if a.pos[1] + xoff < 1
            xoff = 0
        elseif a.pos[1] + xoff > xdim
            xoff = 0
        end

        if a.pos[2] + yoff < 1
            yoff = 0
        elseif a.pos[2] + yoff > ydim
            yoff = 0
        end

        Tuple([xoff, yoff])
    end

    f = Figure(size = (600, 750))

    #time_increments = [100, 700, 800, 1400, 2000, 5000]

    titles = [rich("time ", rich("t", font=:bold_italic), " = $(cumsum(time_increments)[i])") for i in 1:6]

    ax1 = Axis(f[1, 1], title = titles[1])
    ax2 = Axis(f[1, 2], title = titles[2])
    ax3 = Axis(f[2, 1], title = titles[3])
    ax4 = Axis(f[2, 2], title = titles[4])
    ax5 = Axis(f[3, 1], title = titles[5])
    ax6 = Axis(f[3, 2], title = titles[6])

    axes = [ax1, ax2, ax3, ax4, ax5, ax6]

    for i in 1:6
        step!(mod, time_increments[i])
        abmobs = Agents.abmplot!(axes[i], 
                                 mod;
                                 agent_color = agent_color,
                                 agent_marker = agent_marker,
                                 agent_size = agent_size,
                                 offset = offset_fun,
                                 colorrange=(0, 1))

        hidedecorations!(axes[i])
    end

    Colorbar(f[4, 2], limits = (0, 1), colormap = cm, vertical = false, label = rich("weight on ", rich("G", font=:italic), subscript("1")), labelrotation = 0, flipaxis = false, width = 150)

    elem1 = MarkerElement(color = :black, marker = :cross, markersize = 13)
    elem2 = MarkerElement(color = :black, marker = :xcross, markersize = 13)
    Legend(f[4, 1], [elem1, elem2], ["L1", "L2"], valign = :top, framevisible = false, orientation = :horizontal, margin = (0.0f0, 15, 10, 10))

    colsize!(f.layout, 1, Relative(1/2))
    colsize!(f.layout, 2, Relative(1/2))

    f
end


fig = illustrate_onerun_on_lattice("parameters/onerun.json")
save("../plots/lat.pdf", fig)


df = CSV.read("../output/onerun.csv", DataFrame)
fig = plot_onerun(df)
save("../plots/ts.pdf", fig)



