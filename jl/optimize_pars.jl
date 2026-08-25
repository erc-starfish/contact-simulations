using Distributions
using ABCdeZ


# lower and upper bounds for parameters
OPT_LBS = Dict(:birthrate => 0.001, 
	       :sigma => 0.01, 
	       :min_importtime => 1, 
	       :importperiod => 10, 
	       :n_seed => 10, 
	       :weibull_shape => 1.0, 
	       :weibull_scale => 10.0, 
	       :carcap => 10_000, 
	       :immig_shape => 1.0, 
	       :immig_scale => 1.0)

OPT_UBS = Dict(:birthrate => 0.1, 
	       :sigma => 0.99, 
	       :min_importtime => 100, 
	       :importperiod => 1000, 
	       :n_seed => 1000, 
	       :weibull_shape => 10.0, 
	       :weibull_scale => 75.0, 
	       :carcap => 500_000, 
	       :immig_shape => 10.0, 
	       :immig_scale => 10.0)

OPT_NONUNI_LBS = Dict(:birthrate => 0.0, 
	       :sigma => 0.0, 
	       :min_importtime => 0, 
	       :importperiod => 0, 
	       :n_seed => 0, 
	       :weibull_shape => 0.0, 
	       :weibull_scale => 0.0, 
	       :carcap => 45_000, 
	       :immig_shape => 0.0, 
	       :immig_scale => 0.0)

OPT_NONUNI_UBS = Dict(:birthrate => 0.1, 
	       :sigma => 1.0, 
	       :min_importtime => 100, 
	       :importperiod => 500, 
	       :n_seed => 1000, 
	       :weibull_shape => 10.0, 
	       :weibull_scale => 100.0, 
	       :carcap => 55_000, 
	       :immig_shape => 10.0, 
	       :immig_scale => 10.0)


trnormal = "\\textnormal{TrNormal}"
binomial = "\\textnormal{Bin}"

OPT_PRIORNAMES = Dict(:birthrate => "$trnormal (0.05, 0.01); [0, 1]", 
		      :sigma => "$trnormal (0.5, 0.1); [0, 1]", 
		      :min_importtime => "$binomial (100, 0.5)", 
		      :importperiod => "$binomial (500, 0.5)", 
		      :n_seed => "$binomial (1000, 0.5)", 
		      :weibull_shape => "$trnormal (5, 1); [0, 10]", 
		      :weibull_scale => "$trnormal (50, 10); [0, 100]", 
		      :carcap => "$binomial (10^5, 0.5)", 
		      :immig_shape => "$trnormal (5, 0.1); [0, 10]", 
		      :immig_scale => "$trnormal (5, 0.5); [0, 10]")


PRIORS_NONUNI = [truncated(Normal(0.05, 0.01), 0.0, 1.0),         # birthrate
		 truncated(Normal(0.5, 0.1), 0.0, 1.0),          # sigma
		 Binomial(100, 0.5),                              # min_importtime
		 Binomial(500, 0.5),                              # importperiod
		 Binomial(1000, 0.5),                             # n_seed
		 truncated(Normal(5, 1), 0.0, 10.0),              # weibull_shape
		 truncated(Normal(50, 10), 0.0, 100.0),           # weibull_scale
		 Binomial(100_000, 0.5),                          # carcap
		 truncated(Normal(5, 0.1), 0.0, 10.0),             # immig_shape
		 truncated(Normal(5, 0.5), 0.0, 10.0)]            # immig_scale

PRIORS_UNI = [Uniform(        OPT_LBS[:birthrate],        OPT_UBS[:birthrate]),
	      Uniform(        OPT_LBS[:sigma],            OPT_UBS[:sigma]),
	      DiscreteUniform(OPT_LBS[:min_importtime],   OPT_UBS[:min_importtime]),
	      DiscreteUniform(OPT_LBS[:importperiod],     OPT_UBS[:importperiod]),
	      DiscreteUniform(OPT_LBS[:n_seed],           OPT_UBS[:n_seed]),
	      Uniform(        OPT_LBS[:weibull_shape],    OPT_UBS[:weibull_shape]),
	      Uniform(        OPT_LBS[:weibull_scale],    OPT_UBS[:weibull_scale]),
	      DiscreteUniform(OPT_LBS[:carcap],           OPT_UBS[:carcap]),
	      Uniform(        OPT_LBS[:immig_shape],      OPT_UBS[:immig_shape]),
	      Uniform(        OPT_LBS[:immig_scale],      OPT_UBS[:immig_scale])]

#PRIORS = PRIORS_UNI
PRIORS = PRIORS_NONUNI

OPT_PRIORS = ABCdeZ.Factored(PRIORS...)
