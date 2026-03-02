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
    "numba"       => "Numba",
    "python"      => "Python",
    "octave"      => "Octave",
    "r"           => "R",
    "go"          => "Go",
    "rust"        => "Rust",
    "scala"       => "Scala",
    "swift"       => "Swift",
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

# Color palette — one color per benchmark (matching julialang.org/benchmarks style)
const COLORS = [
    "rgb(0, 190, 210)",
    "rgb(220, 50, 50)",
    "rgb(150, 150, 150)",
    "rgb(0, 170, 170)",
    "rgb(170, 140, 210)",
    "rgb(230, 130, 180)",
    "rgb(220, 200, 50)",
    "rgb(80, 180, 80)",
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

Generate a Documenter-compatible Markdown page with a Chart.js scatter plot
in the style of julialang.org/benchmarks (colored dots, log scale, languages
on x-axis).
"""
function make_chart(benchfile::String, versions::Dict{String, String}=Dict{String, String}())
    benchmarks = parse_benchmarks(benchfile)
    langs = sorted_languages(benchmarks)
    c_times = benchmarks["c"]

    labels_json = "[" * join(["\"$(get(LANG_LABELS, l, l))\"" for l in langs], ",") * "]"

    # Each benchmark becomes a scatter dataset with {x: lang_index, y: relative_time}
    datasets = String[]
    for (i, bench) in enumerate(BENCHMARK_ORDER)
        points = String[]
        for (j, lang) in enumerate(langs)
            t = get(get(benchmarks, lang, Dict()), bench, NaN)
            rel = t / c_times[bench]
            isnan(rel) && continue
            push!(points, @sprintf("{x:%d,y:%.4f}", j - 1, rel))
        end
        push!(datasets, """{
                label: "$bench",
                data: [$(join(points, ","))],
                backgroundColor: "$(COLORS[i])",
                borderColor: "$(COLORS[i])",
                pointRadius: 3.5,
                pointHoverRadius: 5,
                pointStyle: "circle"
            }""")
    end

    datasets_json = join(datasets, ",\n            ")

    html = """
    Each dot represents one benchmark for a given language, with time normalized to C (lower is better).

    ```@raw html
    <canvas id="benchChart" style="max-height:550px;"></canvas>
    <script>
    // Use require() to load Chart.js so it works with Documenter.jl's RequireJS
    require.config({ paths: { chartjs: "https://cdn.jsdelivr.net/npm/chart.js/dist/chart.umd.min" } });
    require(["chartjs"], function(Chart) {
        var langLabels = $labels_json;
        new Chart(document.getElementById("benchChart"), {
            type: "scatter",
            data: {
                datasets: [
                $datasets_json
                ]
            },
            options: {
                responsive: true,
                plugins: {
                    title: {
                        display: true,
                        text: "Benchmark times relative to C (lower is better)",
                        font: { size: 15 }
                    },
                    legend: {
                        position: "right",
                        labels: { usePointStyle: true, pointStyle: "circle", padding: 14 }
                    },
                    tooltip: {
                        callbacks: {
                            title: function(items) {
                                return langLabels[items[0].parsed.x];
                            },
                            label: function(item) {
                                return item.dataset.label + ": " + item.parsed.y.toFixed(2) + "x";
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        type: "linear",
                        min: -0.5,
                        max: $(length(langs) - 1).5,
                        afterBuildTicks: function(axis) {
                            axis.ticks = langLabels.map(function(_, i) { return { value: i }; });
                        },
                        ticks: {
                            autoSkip: false,
                            maxRotation: 45,
                            callback: function(value) {
                                return langLabels[value] || "";
                            }
                        },
                        grid: { display: false }
                    },
                    y: {
                        type: "logarithmic",
                        title: { display: true, text: "Time relative to C (log scale)" },
                        min: 0.1,
                        grid: { color: "rgba(0,0,0,0.08)" },
                        ticks: {
                            callback: function(value) {
                                if ([0.1, 1, 10, 100, 1000, 10000].indexOf(value) >= 0)
                                    return value.toString();
                                return "";
                            }
                        }
                    }
                }
            }
        });
    });
    </script>
    ```
    """

    # Generate per-language tables
    lang_tables = make_language_tables(benchmarks, langs, c_times, versions)

    open("docs/src/benchmarks.md", "w") do io
        print(io, html)
        println(io)
        println(io)
        print(io, lang_tables)
    end
end

"""
    make_language_tables(benchmarks, langs, c_times) -> String

Generate a Markdown section with a table for each language showing
benchmark names, absolute times (ms), and times relative to C.
"""
function make_language_tables(benchmarks, langs, c_times, versions=Dict{String, String}())
    io = IOBuffer()
    println(io, "## Results by language")
    println(io)
    println(io, "[Download raw benchmark data (CSV)](benchmarks.csv)")
    println(io)
    for lang in langs
        label = get(LANG_LABELS, lang, lang)
        times = get(benchmarks, lang, Dict{String, Float64}())
        isempty(times) && continue
        ver = get(versions, lang, "")
        heading = isempty(ver) ? "### $label" : "### $label ($ver)"
        println(io, heading)
        println(io)
        println(io, "| Benchmark | Time (ms) | Relative to C |")
        println(io, "|:----------|----------:|--------------:|")
        for bench in BENCHMARK_ORDER
            t = get(times, bench, NaN)
            isnan(t) && continue
            rel = t / c_times[bench]
            println(io, @sprintf("| `%s` | %.2f | %.2fx |", bench, t, rel))
        end
        println(io)
    end
    return String(take!(io))
end

benchmarks_csv = get(ARGS, 1, "gh_action_benchmarks.csv")
versions_csv   = get(ARGS, 2, "gh_action_versions.csv")

versions = parse_versions(versions_csv)
make_chart(benchmarks_csv, versions)

# Copy CSV into docs/src/ so it is available for download in the built site
cp(benchmarks_csv, "docs/src/benchmarks.csv"; force=true)

makedocs(
    format = Documenter.HTML(collapselevel = 3),
    sitename = "Julia Microbenchmarks",
    pages = [
        "Microbenchmarks" => "index.md",
        "Benchmarks" => "benchmarks.md",
        "Notes" => "notes.md",
    ],
)

deploydocs(
    repo = "github.com/JuliaLang/Microbenchmarks.git",
    target = "build",
    deps   = nothing,
    make   = nothing,
    push_preview = true,
)
