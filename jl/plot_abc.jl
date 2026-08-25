using CairoMakie
using DataFrames
using Distributions
using Serialization

include("optimize_pars.jl")

include("Asteroidea.jl")
using .Asteroidea

for dataset in ["APS", "Afrikaans"]
    data = deserialize("../output/abc_$dataset.jls")


    # lower and upper bounds for parameters
    temporary = DataFrame(Symbol(k) => v for (k, v) in pairs(OPT_NONUNI_LBS))
    lbs = [subset(temporary, :first => x -> x .== :birthrate).second[1],
           subset(temporary, :first => x -> x .== :sigma).second[1],
           subset(temporary, :first => x -> x .== :min_importtime).second[1],
           subset(temporary, :first => x -> x .== :importperiod).second[1],
           subset(temporary, :first => x -> x .== :n_seed).second[1],
           subset(temporary, :first => x -> x .== :weibull_shape).second[1],
           subset(temporary, :first => x -> x .== :weibull_scale).second[1],
           subset(temporary, :first => x -> x .== :carcap).second[1],
           subset(temporary, :first => x -> x .== :immig_shape).second[1],
           subset(temporary, :first => x -> x .== :immig_scale).second[1]]

    temporary = DataFrame(Symbol(k) => v for (k, v) in pairs(OPT_NONUNI_UBS))
    ubs = [subset(temporary, :first => x -> x .== :birthrate).second[1],
           subset(temporary, :first => x -> x .== :sigma).second[1],
           subset(temporary, :first => x -> x .== :min_importtime).second[1],
           subset(temporary, :first => x -> x .== :importperiod).second[1],
           subset(temporary, :first => x -> x .== :n_seed).second[1],
           subset(temporary, :first => x -> x .== :weibull_shape).second[1],
           subset(temporary, :first => x -> x .== :weibull_scale).second[1],
           subset(temporary, :first => x -> x .== :carcap).second[1],
           subset(temporary, :first => x -> x .== :immig_shape).second[1],
           subset(temporary, :first => x -> x .== :immig_scale).second[1]]

    # priors
    priors = PRIORS



    fig = Figure(size=(600,800))

    titles = [rich("(a) Birth rate (", rich("b", font=:bold_italic), ")"),
              rich("(b) Expected prop. of L2 speakers (E[", rich("σ", font=:bold_italic), "])"),
              rich("(c) Contact start time (", rich("T", font=:bold_italic), subsup("L2", "0"), ")"),
              rich("(d) Length of contact (", rich("T", font=:bold_italic), subscript("L2"), ")"),
              rich("(e) Number of L1 speakers at time 0 (", rich("N", font=:bold_italic), subscript("0"), ")"),
              rich("(f) Shape of death distribution (", rich("k", font=:bold_italic), ")"),
              rich("(g) Scale of death distribution (", rich("λ", font=:bold_italic), ")"),
              rich("(h) Carrying capacity (", rich("K", font=:bold_italic), ")"),
              rich("(i) Shape of imm. age distribution (", rich("ϕ", font=:bold_italic), ")"),
              rich("(j) Scale of imm. age distribution (", rich("θ", font=:bold_italic), ")")]

    ax1 = Axis(fig[1,1], title=titles[1], titlealign=:left, yticklabelsvisible=false)#, yticksvisible=false, xgridvisible=false, ygridvisible=false)
    ax2 = Axis(fig[1,2], title=titles[2], titlealign=:left, yticklabelsvisible=false)#, yticksvisible=false, xgridvisible=false, ygridvisible=false)
    ax3 = Axis(fig[2,1], title=titles[3], titlealign=:left, yticklabelsvisible=false)#, yticksvisible=false, xgridvisible=false, ygridvisible=false)
    ax4 = Axis(fig[2,2], title=titles[4], titlealign=:left, yticklabelsvisible=false, xticks = [0, 250, 500])#, yticksvisible=false, xgridvisible=false, ygridvisible=false)
    ax5 = Axis(fig[3,1], title=titles[5], titlealign=:left, yticklabelsvisible=false)#, yticksvisible=false, xgridvisible=false, ygridvisible=false)
    ax6 = Axis(fig[3,2], title=titles[6], titlealign=:left, yticklabelsvisible=false)#, yticksvisible=false, xgridvisible=false, ygridvisible=false)
    ax7 = Axis(fig[4,1], title=titles[7], titlealign=:left, yticklabelsvisible=false)#, yticksvisible=false, xgridvisible=false, ygridvisible=false)
    ax8 = Axis(fig[4,2], title=titles[8], titlealign=:left, yticklabelsvisible=false, xticks = [45000, 50000, 55000])#, yticksvisible=false, xgridvisible=false, ygridvisible=false)
    ax9 = Axis(fig[5,1], title=titles[9], titlealign=:left, yticklabelsvisible=false)#, yticksvisible=false, xgridvisible=false, ygridvisible=false)
    ax10 = Axis(fig[5,2], title=titles[10], titlealign=:left, yticklabelsvisible=false)#, yticksvisible=false, xgridvisible=false, ygridvisible=false)


    axes = [ax1, ax2, ax3, ax4, ax5, ax6, ax7, ax8, ax9, ax10]


    for i in 1:10
        if i ∈ [3, 4, 5, 8]
            xx = lbs[i]:1:ubs[i]
        else
            xx = range(lbs[i], ubs[i], 100)
        end

        xscale = maximum(xx) - minimum(xx)

        lines!(axes[i], xx, pdf(priors[i], xx), color = starfish_yellow, linewidth = 2.0)
        band!(axes[i], xx, range(0, 0, length(xx)), pdf(priors[i], xx), color=(starfish_yellow, 0.7), label="prior")

        #hist!(axes[i], [t[i] for t in data.P[data.Wns .> 0.0]], normalization = :pdf, color=(starfish_blue, 0.8), strokecolor = (starfish_blue, 0.8), strokewidth = 0.0, label="posterior")
	density!(axes[i], [t[i] for t in data.P[data.Wns .> 0.0]], bandwidth=0.01*xscale, color=(starfish_blue, 0.6), label="posterior")
    end

    Legend(fig[6,2], axes[1], framevisible=false, orientation=:horizontal)

    colsize!(fig.layout, 1, Relative(1/2))
    colsize!(fig.layout, 2, Relative(1/2))
    #colsize!(fig.layout, 3, Relative(1/3))

    save("../plots/abc-$dataset.pdf", fig)

end
