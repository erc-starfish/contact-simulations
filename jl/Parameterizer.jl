module Parameterizer

import JSON
import InteractiveUtils

export parse_parameters
export print_parameters_md


# parse model parameters from JSON file
function parse_parameters(parfile)
    pardict = open(parfile, "r") do f
        JSON.parse(f)
    end

    meta = pardict["meta"]

    pardict = pardict["parameters"]

    modelpars = Dict{Symbol, Any}()

    for (k,v) in pardict
        type = Meta.eval(Meta.parse(pardict[k]["type"]))
        if "val" ∈ keys(pardict[k])
            if AbstractVector{Any} ∈ InteractiveUtils.supertypes(typeof(pardict[k]["val"]))
                modelpars[Symbol(k)] = convert.(type, pardict[k]["val"])
            else
                modelpars[Symbol(k)] = [convert(type, pardict[k]["val"])]
            end
        elseif "min" ∈ keys(pardict[k])
            if "modifier" ∈ keys(pardict[k]) && pardict[k]["modifier"] == "log2"
                modelpars[Symbol(k)] = convert.(type, 2 .^ range(log2(pardict[k]["min"]), log2(pardict[k]["max"]), pardict[k]["len"]))
            elseif "modifier" ∈ keys(pardict[k]) && pardict[k]["modifier"] == "log10"
                modelpars[Symbol(k)] = convert.(type, 10 .^ range(log10(pardict[k]["min"]), log10(pardict[k]["max"]), pardict[k]["len"]))
            elseif "modifier" ∈ keys(pardict[k]) && pardict[k]["modifier"] == "log"
                modelpars[Symbol(k)] = convert.(type, exp.(range(log(pardict[k]["min"]), log(pardict[k]["max"]), pardict[k]["len"])))
            else
                tmp = range(pardict[k]["min"], pardict[k]["max"], pardict[k]["len"])
                if type ∈ [Int, Int64]
                    tmp = trunc.(Int, collect(tmp))
                end
                modelpars[Symbol(k)] = convert.(type, tmp)
            end
        end
    end

    return meta, modelpars
end


# print parameters as a Markdown table
function print_parameters_md(filename::String,
        parlist::String;
        io::IO = stdout,
        header = ["Parameter", "Symbol", "Value(s)"],
        just = [:left, :left, :right],
        width = [10, 10, 10])
    # read in parameters from JSON file
    pars = open(filename, "r") do f
        JSON.parse(f)["parameters"]
    end

    # read master list
        mlist = open(parlist, "r") do f
            JSON.parse(f)
        end

    parameters = mlist["meta"]["default_order"]
    mlist = mlist["parameters"]

    # print table header
    println(io, "| $(header[1]) | $(header[2]) | $(header[3]) |")
    print(io, "|")
    for i in 1:3
        just[i] == :right ? print(io, "") : print(io, ":")
        print(io, repeat("-", width[i]))
        just[i] == :left ? print(io, "") : print(io, ":")
        print(io, "|")
    end
    println(io)

    # cycle through parameters (will be rows of the table)
    for key in parameters
        val = pars[key]
        listval = mlist[key]

        # don't print values which agree with the 
        # default values in the master list
        shouldcontinue = true
        if parlist != ""
            if parlist != filename
                if "val" ∈ keys(val)
                    if val["val"] == listval["val"]
                        shouldcontinue = false
                    end
                end
            end
        end

        shouldcontinue && begin
            print(io, "| ")
            print(io, listval["description"])
            print(io, " | ")
            print(io, listval["symbol"])
            print(io, " | ")

            if "val" ∈ keys(val)
                if AbstractVector{Any} ∈ InteractiveUtils.supertypes(typeof(val["val"]))
                    # if val is a vector, we need to do something fancy
                    print(io, val["val"][1])
                    for i in 2:length(val["val"])
                        print(io, ", ")
                        print(io, val["val"][i])
                    end
                else
                    # otherwise it's just a matter of printing the value
                    print(io, val["val"])
                end
            end

            if "min" ∈ keys(val)
                if "modifier" ∈ keys(val)
                    if val["modifier"] == "log10"
                        print(io, "\$\\log_{10}\$")
                    elseif val["modifier"] == "log2"
                        print(io, "\$\\log_{2}\$")
                    elseif val["modifier"] == "log"
                        print(io, "\$\\log\$")
                    end
                end

                print(io, "[")
                print(io, val["min"])
                print(io, " \$\\stackrel{")
                print(io, val["len"])
                print(io, "}{\\ldots}\$ ")
                print(io, val["max"])
                print(io, "]")

            end

            print(io, " |")
            println(io)
        end
    end
end


# print parameters as a LaTeX table
function print_parameters_tex(filename::String,
        parlist::String;
        io::IO = stdout,
        header = ["Parameter", "Symbol", "Value(s)"],
        just = ["l", "l", "r"],
        caption = "",
        label = "",
        width = [10, 10, 10])
    # read in parameters from JSON file
    pars = open(filename, "r") do f
        JSON.parse(f)["parameters"]
    end

    # read master list
        mlist = open(parlist, "r") do f
            JSON.parse(f)
        end

    parameters = mlist["meta"]["default_order"]
    mlist = mlist["parameters"]

    # print table header
    print(io, "\\begin{table}")
    print(io, "\\caption{$caption}\\label{$label}")
    print(io, "\\begin{tabular}{")
    for i in 1:length(just)
        print(io, just[i])
    end
    println(io, "}")
    println(io, "\\toprule")
    println(io, "$(header[1]) & $(header[2]) & $(header[3]) \\\\")
    println(io, "\\midrule")

    # cycle through parameters (will be rows of the table)
    for key in parameters
        val = pars[key]
        listval = mlist[key]

        # don't print values which agree with the 
        # default values in the master list
        shouldcontinue = true
        if parlist != ""
            if parlist != filename
                if "val" ∈ keys(val)
                    if val["val"] == listval["val"]
                        shouldcontinue = false
                    end
                end
            end
        end

        shouldcontinue && begin
            print(io, listval["description"])
            print(io, " & ")
            print(io, listval["symbol"])
            print(io, " & ")

            if "val" ∈ keys(val)
                if AbstractVector{Any} ∈ InteractiveUtils.supertypes(typeof(val["val"]))
                    # if val is a vector, we need to do something fancy
                    print(io, val["val"][1])
                    for i in 2:length(val["val"])
                        print(io, ", ")
                        print(io, val["val"][i])
                    end
                else
                    # otherwise it's just a matter of printing the value
                    print(io, val["val"])
                end
            end

            if "min" ∈ keys(val)
                if "modifier" ∈ keys(val)
                    if val["modifier"] == "log10"
                        print(io, "\$\\log_{10}\$")
                    elseif val["modifier"] == "log2"
                        print(io, "\$\\log_{2}\$")
                    elseif val["modifier"] == "log"
                        print(io, "\$\\log\$")
                    end
                end

                print(io, "[")
                print(io, val["min"])
                print(io, " \$\\stackrel{")
                print(io, val["len"])
                print(io, "}{\\ldots}\$ ")
                print(io, val["max"])
                print(io, "]")

            end

            print(io, " \\\\")
            println(io)
        end
    end
    println(io, "\\bottomrule")
    println(io, "\\end{tabular}")
    println(io, "\\end{table}")
end



end
