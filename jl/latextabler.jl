function latextabler(io,
        df;
        alignment = "",
        header = "", 
        caption = "", 
        label = "")
    println(io, "\\begin{table}")
    println(io, "\\caption{$caption}\\label{$label}")
    println(io, "\\begin{tabular}{$alignment}")
    println(io, "\\toprule")
    print(io, join(string.(header), " & "))
    println(io, "\\\\")
    println(io, "\\midrule")

    for row in eachrow(df)
        print(io, join(string.(collect(row)), " & "))
        println(io, "\\\\")
    end

    println(io, "\\bottomrule")
    println(io, "\\end{tabular}")
    println(io, "\\end{table}")
end
