# visualize birth death etc. distributions
#


include("Asteroidea.jl")

using .Asteroidea
using CairoMakie
using Distributions


# parameters
β = 0.09
τ = 0.04
#m = 30.0
#s = 18.0
m = 6.0
s = 5.0
k = 10.0
λ = 70.0
K = 2000
N = 1000


x = -10:110
x2 = -10:0.1:110


# distributions
birth = Binomial(floor(N*(1 - N/K)), β)
immig = Binomial(floor(N*(1 - N/K)), τ)
age = Truncated(Normal(m, s), 0.0, λ)
age = Gamma(m, s)
death = Weibull(k, λ)


fig = Figure(size=(600,500))

ax1 = Axis(fig[1,1], title="(a) Number of births", titlealign=:left, xlabel="individuals")
ax2 = Axis(fig[1,2], title="(b) Number of immigrants", titlealign=:left, xlabel="individuals")
ax3 = Axis(fig[2,1], title="(c) Age at immigration", titlealign=:left, xlabel="years")
ax4 = Axis(fig[2,2], title="(d) Life expectancy", titlealign=:left, xlabel="years")

barplot!(ax1, x, pdf(birth, x), color=Asteroidea.starfish_blue, alpha=0.75, gap=0.0)
barplot!(ax2, x, pdf(immig, x), color=Asteroidea.starfish_blue, alpha=0.75, gap=0.0)
lines!(ax3, x2, pdf(age, x2), color=Asteroidea.starfish_blue, linewidth=1.5)
lines!(ax4, x2, pdf(death, x2), color=Asteroidea.starfish_blue, linewidth=1.5)

#band!(ax1, x, range(0, 0, length(x)), pdf(birth, x), color=Asteroidea.starfish_blue, alpha=0.5)
#band!(ax2, x, range(0, 0, length(x)), pdf(immig, x), color=Asteroidea.starfish_blue, alpha=0.5)
band!(ax3, x2, range(0, 0, length(x2)), pdf(age, x2), color=Asteroidea.starfish_blue, alpha=0.5)
band!(ax4, x2, range(0, 0, length(x2)), pdf(death, x2), color=Asteroidea.starfish_blue, alpha=0.5)

text!(ax1, 0.67, 0.6; space=:relative, text=rich(rich("b", font=:italic), " = $β\n", rich("N", font=:italic), " = $N\n", rich("K", font=:italic), " = $K"))
text!(ax2, 0.67, 0.6; space=:relative, text=rich(rich("τ", font=:italic), " = $τ\n", rich("N", font=:italic), " = $N\n", rich("K", font=:italic), " = $K"))
text!(ax3, 0.67, 0.7; space=:relative, text=rich(rich("ϕ", font=:italic), " = $m\n", rich("θ", font=:italic), " = $s"))
text!(ax4, 0.1, 0.7; space=:relative, text=rich(rich("k", font=:italic), " = $k\n", rich("λ", font=:italic), " = $λ"))

save("../plots/distros.pdf", fig)
