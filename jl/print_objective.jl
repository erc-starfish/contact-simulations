using JSON
using Pipe


aps_transient = open("../meta/popdyn_APS_transient.json", "r") do f
    @pipe JSON.parse(f)["meta"]["objective_value"] |> round(_; digits=2)
end

aps_eternal = open("../meta/popdyn_APS_eternal.json", "r") do f
    @pipe JSON.parse(f)["meta"]["objective_value"] |> round(_; digits=2)
end

afri_transient = open("../meta/popdyn_Afrikaans_transient.json", "r") do f
    @pipe JSON.parse(f)["meta"]["objective_value"] |> round(_; digits=2)
end

afri_eternal = open("../meta/popdyn_Afrikaans_eternal.json", "r") do f
    @pipe JSON.parse(f)["meta"]["objective_value"] |> round(_; digits=2)
end


caption = "Values of the objective function at the optimized values of the socio-dynamic parameters."
label = "tbl:objectivevalues"


open("../tables/objective-values.tex", "w") do f
    println(f, "\\begin{table}")
    println(f, "\\caption{$caption}\\label{$label}")
    println(f, "\\begin{tabular}{lrr}")
    println(f, "\\toprule")
    println(f, " & Afro-Peruvian Spanish & Afrikaans \\\\")
    println(f, "\\midrule")
    println(f, "L2 learning cut off & $aps_transient & $afri_transient \\\\")
    println(f, "L2 learning not cut off & $aps_eternal & $afri_eternal \\\\")
    println(f, "\\bottomrule")
    println(f, "\\end{tabular}")
    println(f, "\\end{table}")
end


