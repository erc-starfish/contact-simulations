using CSV, DataFrames
include("latextabler.jl")


# prepare data
data_afrikaans = CSV.read("../data/afrikaans.csv", DataFrame)
transform!(data_afrikaans, :Europeans => (x -> x) => :Euro)
transform!(data_afrikaans, ["Free Blacks", "Slaves"] => ((a,b) -> a .+ b) => :nonEuro)

data_aps = CSV.read("../data/aps.csv", DataFrame)
transform!(data_aps, :Spanish => (x -> x) => :Euro)
transform!(data_aps, [:Black, :Indigenous] => ((a,b) -> a .+ b) => :nonEuro)


# pretty-print
select!(data_afrikaans, [:Year, :Euro, :nonEuro])
open("../tables/data-afrikaans.tex", "w") do f
    latextabler(f, data_afrikaans; alignment = "lrr", header = ["Year", "Europeans", "Non-Europeans"], caption = "Demographic data for Afrikaans (from \\cite{GilElph1979} by way of \\cite{Kauhanen2022}). Numbers for the indigenous (Khoekhoe) population are only available for years 1798 and 1820; as these numbers cannot be reliably imputed for the earlier years, the indigenous are not included in the numbers shown here.", label = "tbl:data-afrikaans")
end

select!(data_aps, [:Year, :Euro, :nonEuro])
open("../tables/data-aps.tex", "w") do f
    latextabler(f, data_aps; alignment = "lrr", header = ["Year", "Europeans", "Non-Europeans"], caption = "Demographic data for Afro-Peruvian Spanish (from \\cite{Bow1974} by way of \\cite{Kauhanen2022}). The category ``mixed'', included in the original counts in \\textcite{Bow1974}, has been dropped as it is unclear whether people of mixed background in the censuses ought to be counted as European or not.", label = "tbl:data-aps")
end


