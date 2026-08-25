include("Parameterizer.jl")
using .Parameterizer


# master list of parameters
mlist = "parameters/list_of_parameters.json"


# cycle through all parameter combos we want to print
to_print = ["bifurcation", "bifurcation_long", "latshape", "onerun", "list_of_parameters"]

# column widths for each table
colw = Dict(
            "bifurcation" => [70, 20, 40],
            "bifurcation_long" => [70, 20, 40],
            "latshape" => [70, 20, 40],
            "onerun" => [70, 15, 15],
            "list_of_parameters" => [70, 15, 15]
           )

# captions and labels
caps = Dict(
            "bifurcation" => "Model parameters for the sweep of Figure \\ref{fig:bifu}. For the values of the constant parameters, consult Table \\ref{tbl:parameters}. In this and subsequent tables, the notation \$[a \\stackrel{n}{\\dots} b]\$ refers to a sequence of \$n\$ equally-spaced values from \$a\$ to \$b\$ (endpoints inclusive). The notation \$\\log_{10}[a \\stackrel{n}{\\dots} b]\$ refers to such a sequence with logarithmic spacing.",
            "bifurcation_long" => "Model parameters for the sweep of Figure \\ref{fig:bifu}. For the values of the constant parameters, consult Table \\ref{tbl:parameters}. In this and subsequent tables, the notation \$[a \\stackrel{n}{\\dots} b]\$ refers to a sequence of \$n\$ equally-spaced values from \$a\$ to \$b\$ (endpoints inclusive). The notation \$\\log_{10}[a \\stackrel{n}{\\dots} b]\$ refers to such a sequence with logarithmic spacing.",
            "latshape" => "Model parameters for the sweep of Figure \\ref{fig:latshape}. For the values of the constant parameters, consult Table \\ref{tbl:parameters}.",
            "onerun" => "Model parameters for the simulation depicted in Figures \\ref{fig:ts}--\\ref{fig:lat}. For the values of the constant parameters, consult Table \\ref{tbl:parameters}.",
            "list_of_parameters" => "Overview of model parameters for the agent-based simulations in Sections \\ref{sec:simulation-setup}--\\ref{sec:sweeps}. Parameters which are held constant across all simulations reported in this and the following section are indicated with those constant values. Parameters with values labelled `various' were varied across simulations, as explained in more detail below."
           )

labs = Dict(
            "bifurcation" => "tbl:bifu",
            "bifurcation_long" => "tbl:bifu",
            "latshape" => "tbl:latshape",
            "onerun" => "tbl:onerun",
            "list_of_parameters" => "tbl:parameters"
           )


for combo in to_print
    open("../tables/$combo.tex", "w") do f
        Parameterizer.print_parameters_tex("parameters/$combo.json",
                                          mlist;
                                          io = f,
                                          just = ["l", "c", "r"],
                                          caption = caps[combo],
                                          label = labs[combo],
                                          width = colw[combo])
    end
end


