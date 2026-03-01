using Documenter
using Statistics
using Printf

const LANG_LABELS = Dict(
    "c"           => "C",
    "julia"       => "Julia",
    "lua"         => "LuaJIT",
    "fortran"     => "Fortran",
    "java"        => "Java",
    "javascript"  => "JavaScript",
    "matlab"      => "Matlab",
    "mathematica" => "Mathematica",
    "python"      => "Python",
    "octave"      => "Octave",
    "r"           => "R",
    "go"          => "Go",
    "rust"        => "Rust",
)

const BENCHMARK_ORDER = [
    "iteration_pi_sum",
    "recursion_fibonacci",
    "recursion_quicksort",
    "parse_integers",
    "print_to_file",
    "matrix_statistics",
    "matrix_multiply",
    "userfunc_mandelbrot",
]

# Chart.js color palette — one color per benchmark
const COLORS = [
    "rgba(31, 119, 180, 0.85)",
    "rgba(255, 127, 14, 0.85)",
    "rgba(44, 160, 44, 0.85)",
    "rgba(214, 39, 40, 0.85)",
    "rgba(148, 103, 189, 0.85)",
    "rgba(140, 86, 75, 0.85)",
    "rgba(227, 119, 194, 0.85)",
    "rgba(127, 127, 127, 0.85)",
]

const BORDER_COLORS = [
    "rgb(31, 119, 180)",
    "rgb(255, 127, 14)",
    "rgb(44, 160, 44)",
    "rgb(214, 39, 40)",
    "rgb(148, 103, 189)",
    "rgb(140, 86, 75)",
    "rgb(227, 119, 194)",
    "rgb(127, 127, 127)",
]

"""
    parse_benchmarks(path) -> Dict{String, Dict{String, Float64}}

Parse a headerless CSV with columns: language, benchmark, time.
Returns `Dict(language => Dict(benchmark => time))`.
"""
function parse_benchmarks(path::String)
    data = Dict{String, Dict{String, Float64}}()
    for line in eachline(path)
        isempty(strip(line)) && continue
        lang, bench, time_str = split(line, ',')
        times = get!(data, String(lang), Dict{String, Float64}())
        times[String(bench)] = parse(Float64, time_str)
    end
    return data
end

"""
    parse_versions(path) -> Dict{String, String}

Parse a headerless CSV with columns: language, version.
"""
function parse_versions(path::String)
    vers = Dict{String, String}()
    for line in eachline(path)
        isempty(strip(line)) && continue
        lang, version = split(line, ','; limit=2)
        vers[String(lang)] = String(strip(version))
    end
    return vers
end

"""
Sort languages: C first, Julia second, rest by geometric mean of benchmark times.
"""
function sorted_languages(benchmarks::Dict{String, Dict{String, Float64}})
    function sortkey(lang)
        lang == "c" && return (-Inf, "")
        lang == "julia" && return (-floatmax(), "")
        gmean = exp(mean(log.(collect(values(benchmarks[lang])))))
        return (gmean, lang)
    end
    sort!(collect(keys(benchmarks)); by=sortkey)
end

"""
    make_chart(benchfile) -> writes docs/src/benchmarks.md

Generate a Documenter-compatible Markdown page with a Chart.js grouped bar chart.
"""
function make_chart(benchfile::String)
    benchmarks = parse_benchmarks(benchfile)
    langs = sorted_languages(benchmarks)
    c_times = benchmarks["c"]

    # Compute normalized times per benchmark per language
    labels_json = "[" * join(["\"$(get(LANG_LABELS, l, l))\"" for l in langs], ",") * "]"

    datasets = String[]
    for (i, bench) in enumerate(BENCHMARK_ORDER)
        values = String[]
        for lang in langs
            t = get(get(benchmarks, lang, Dict()), bench, NaN)
            rel = t / c_times[bench]
            push!(values, isnan(rel) ? "null" : @sprintf("%.4f", rel))
        end
        push!(datasets, """{
                label: "$bench",
                data: [$(join(values, ","))],
                backgroundColor: "$(COLORS[i])",
                borderColor: "$(BORDER_COLORS[i])",
                borderWidth: 1
            }""")
    end

    datasets_json = join(datasets, ",\n            ")

    html = """
    ```@raw html
    <canvas id="benchChart" style="max-height:500px;"></canvas>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
    new Chart(document.getElementById("benchChart"), {
        type: "bar",
        data: {
            labels: $labels_json,
            datasets: [
            $datasets_json
            ]
        },
        options: {
            responsive: true,
            plugins: {
                title: { display: true, text: "Benchmark times relative to C (lower is better)" },
                legend: { position: "bottom" }
            },
            scales: {
                y: {
                    type: "logarithmic",
                    title: { display: true, text: "Time relative to C" },
                    min: 0.1
                }
            }
        }
    });
    </script>
    ```
    """

    open("docs/src/benchmarks.md", "w") do io
        print(io, html)
    end
end

"""
    make_versions_tbl(versions_file) -> writes docs/src/versions.md

Generate a simple Markdown table of language versions.
"""
function make_versions_tbl(versions_file::String)
    versions = parse_versions(versions_file)
    langs = sort(collect(keys(versions)))

    open("docs/src/versions.md", "w") do io
        println(io, "| Language | Version |")
        println(io, "|:---------|:--------|")
        for lang in langs
            label = get(LANG_LABELS, lang, lang)
            println(io, "| $label | $(versions[lang]) |")
        end
    end
end

make_chart("gh_action_benchmarks.csv")
make_versions_tbl("gh_action_versions.csv")

makedocs(
    format = Documenter.HTML(),
    sitename = "Julia Microbenchmarks",
    pages = [
        "Microbenchmarks" => "index.md",
        "Benchmarks" => "benchmarks.md",
        "Notes" => "notes.md",
        "Versions" => "versions.md",
    ],
)

deploydocs(
    repo = "github.com/JuliaLang/Microbenchmarks.jl.git",
    target = "build",
    deps   = nothing,
    make   = nothing,
    push_preview = true,
)
