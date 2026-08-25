for i in $(seq 1 10);
do
    julia +1.11.4 -p $3 --project=. batch.jl "parameters/generated/optimized_$1$2_$i.json"
done
