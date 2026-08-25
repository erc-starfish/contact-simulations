# prepare folders
#make -f Intensive.mk clean
make -f Intensive.mk prep

# run the "quick stuff"
make -f Intensive.mk batch ID=onerun NPROC=1
make -f Intensive.mk quickstuff

# ABC parameter optimization
make -f Intensive.mk abc LANG=APS & \
	make -f Intensive.mk abc LANG=Afrikaans
wait

# sample from posterior distributions
make -f Intensive.mk sample LANG=APS ITYPE=""
make -f Intensive.mk sample LANG=Afrikaans ITYPE=""
#make -f Intensive.mk sample LANG=Afrikaans ITYPE="_eternal"

# simulations with sampled parameters
make -f Intensive.mk posterior LANG=APS NPROC=10
make -f Intensive.mk posterior LANG=Afrikaans NPROC=10
#make -f Intensive.mk posterior_eternal LANG=Afrikaans NPROC=10

# sweeps
make -f Intensive.mk batch ID=bifurcation_long NPROC=10
make -f Intensive.mk batch ID=latshape NPROC=10
