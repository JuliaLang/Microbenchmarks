#!/usr/bin/env julia

const data = Dict{Tuple{String,String},Float64}()

for arg in ARGS, line in eachline(arg)
    lang, bench, time_str = split(line, ',')
    old_time = get(data, (lang, bench), Inf)
    new_time = parse(Float64, time_str)
    0 < new_time < old_time || continue
    data[lang, bench] = new_time
end

for ((lang, bench), min_time) in sort!(collect(data))
    println("$lang,$bench,$min_time")
end
