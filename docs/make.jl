using Documenter
using Statistics
using Printf

const LANG_LABELS = Dict(
    "c"           => "C",
    "csharp"      => "C#",
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

xml_escape(s) = replace(string(s), "&" => "&amp;", "<" => "&lt;", ">" => "&gt;", "\"" => "&quot;")

# Value of a log-axis tick at 10^k, e.g. "0.1", "1", "1000"
tick_label(k::Integer) = k < 0 ? rstrip(@sprintf("%.*f", -k, 10.0^k), '0') : string(10^k)

"""
    make_svg(benchmarks, langs, c_times; cpu="", standalone=true) -> String

Render the benchmark scatter plot as a static SVG: languages on the x-axis, time
relative to C on a log-scale y-axis, one colored dot per benchmark. Each dot has a
`<title>`, which browsers show as a tooltip on hover.

Text and grid lines use `currentColor`, so the inline SVG on the docs page follows
the page's light or dark theme. A `standalone` SVG (the downloadable file, which
can be embedded with `<img>`) sets its own color, with a dark-mode variant.
"""
function make_svg(benchmarks, langs, c_times; cpu::AbstractString="", standalone::Bool=true)
    W, H = 900, 500
    left, right, top, bottom = 70, 200, isempty(cpu) ? 44 : 62, 90
    plot_w, plot_h = W - left - right, H - top - bottom
    n = length(langs)
    band = plot_w / n

    # Relative times, and the log-axis range in whole decades
    rels = Dict((lang, bench) => benchmarks[lang][bench] / c_times[bench]
                for lang in langs for bench in BENCHMARK_ORDER
                if haskey(benchmarks[lang], bench))
    lo = min(-1, floor(Int, log10(minimum(values(rels)))))
    hi = max(1, ceil(Int, log10(maximum(values(rels)))))
    yof(v) = top + (hi - log10(v)) / (hi - lo) * plot_h
    xof(j) = left + (j - 0.5) * band

    io = IOBuffer()
    println(io, """<svg xmlns="http://www.w3.org/2000/svg" class="mb-chart" viewBox="0 0 $W $H" """ *
                """role="img" aria-labelledby="mb-chart-title" font-family="Helvetica, Arial, sans-serif" font-size="13" """ *
                """style="width:100%;height:auto;max-width:$(W)px">""")
    println(io, "<title id=\"mb-chart-title\">Benchmark times relative to C (lower is better)</title>")
    println(io, "<style>")
    if standalone
        println(io, "  .mb-chart { color: #333; }")
        println(io, "  @media (prefers-color-scheme: dark) { .mb-chart { color: #ddd; } }")
    end
    println(io, "  .mb-chart text { fill: currentColor; }")
    println(io, "  .mb-chart .grid { stroke: currentColor; stroke-opacity: 0.12; }")
    println(io, "  .mb-chart .grid.one { stroke-opacity: 0.45; }")
    println(io, "  .mb-chart .grid.lang { stroke-opacity: 0.05; }")
    println(io, "  .mb-chart .axis { stroke: currentColor; stroke-opacity: 0.5; }")
    println(io, "  .mb-chart .muted { fill-opacity: 0.7; }")
    println(io, "</style>")

    # Title and (optional) CPU line
    cx = left + plot_w / 2
    println(io, @sprintf("""<text x="%.1f" y="22" text-anchor="middle" font-size="16">Benchmark times relative to C (lower is better)</text>""", cx))
    isempty(cpu) || println(io, @sprintf("""<text class="muted" x="%.1f" y="42" text-anchor="middle" font-size="12">All languages run on one machine: %s</text>""", cx, xml_escape(cpu)))

    # Horizontal grid lines and y tick labels, one per decade
    for k in lo:hi
        y = yof(10.0^k)
        cls = k == 0 ? "grid one" : "grid"
        println(io, @sprintf("""<line class="%s" x1="%d" x2="%d" y1="%.1f" y2="%.1f"/>""", cls, left, left + plot_w, y, y))
        println(io, @sprintf("""<text x="%d" y="%.1f" text-anchor="end" dominant-baseline="middle">%s</text>""", left - 8, y, tick_label(k)))
    end
    println(io, @sprintf("""<text transform="translate(18,%.1f) rotate(-90)" text-anchor="middle">Time relative to C (log scale)</text>""", top + plot_h / 2))
    println(io, @sprintf("""<line class="axis" x1="%d" x2="%d" y1="%d" y2="%d"/>""", left, left + plot_w, top + plot_h, top + plot_h))

    # A faint vertical line through each language's dots, and its label underneath
    for (j, lang) in enumerate(langs)
        x, y = xof(j), top + plot_h + 14
        println(io, @sprintf("""<line class="grid lang" x1="%.1f" x2="%.1f" y1="%d" y2="%d"/>""", x, x, top, top + plot_h))
        println(io, @sprintf("""<text transform="translate(%.1f,%d) rotate(-40)" text-anchor="end" dominant-baseline="middle">%s</text>""",
                             x, y, xml_escape(get(LANG_LABELS, lang, lang))))
    end

    # One dot per (language, benchmark)
    for (i, bench) in enumerate(BENCHMARK_ORDER)
        println(io, "<g fill=\"$(COLORS[i])\">")
        for (j, lang) in enumerate(langs)
            rel = get(rels, (lang, bench), nothing)
            rel === nothing && continue
            label = xml_escape(get(LANG_LABELS, lang, lang))
            println(io, @sprintf("""<circle cx="%.1f" cy="%.1f" r="4.5"><title>%s, %s: %.2f× C</title></circle>""",
                                 xof(j), yof(rel), label, bench, rel))
        end
        println(io, "</g>")
    end

    # Legend
    lx, ly = left + plot_w + 24, top + 8
    for (i, bench) in enumerate(BENCHMARK_ORDER)
        y = ly + (i - 1) * 22
        println(io, @sprintf("""<circle cx="%d" cy="%d" r="5" fill="%s"/>""", lx, y, COLORS[i]))
        println(io, @sprintf("""<text x="%d" y="%d" dominant-baseline="middle">%s</text>""", lx + 12, y, bench))
    end

    println(io, "</svg>")
    return String(take!(io))
end

"""
    make_chart(benchfile, versions; cpu="") -> writes docs/src/benchmarks.md and docs/src/benchmarks.svg

Generate the Benchmarks page: a static SVG scatter plot in the style of
julialang.org/benchmarks (inline, so it follows the page theme), followed by a
table per language. The plot is also written to `benchmarks.svg` for download
and embedding elsewhere.
"""
function make_chart(benchfile::String, versions::Dict{String, String}=Dict{String, String}(); cpu::AbstractString="")
    benchmarks = parse_benchmarks(benchfile)
    langs = sorted_languages(benchmarks)
    c_times = benchmarks["c"]

    write("docs/src/benchmarks.svg", make_svg(benchmarks, langs, c_times; cpu, standalone=true))

    open("docs/src/benchmarks.md", "w") do io
        println(io, "Each dot represents one benchmark for a given language, with time normalized to C (lower is better). Hover over a dot to see its value.")
        println(io)
        println(io, "```@raw html")
        print(io, make_svg(benchmarks, langs, c_times; cpu, standalone=false))
        println(io, "```")
        println(io)
        isempty(cpu) || (println(io, "All languages were run on the same machine: `$cpu`."); println(io))
        println(io, "Download the chart as [SVG](benchmarks.svg) and the language versions as [CSV](versions.csv).")
        println(io)
        print(io, make_language_tables(benchmarks, langs, c_times, versions))
    end
end

"""
    make_language_tables(benchmarks, langs, c_times) -> String

Generate a Markdown section with a table for each language showing
benchmark names, absolute times (ms), and times relative to C.
"""
function make_language_tables(benchmarks, langs, c_times, versions=Dict{String, String}())
    io = IOBuffer()
    println(io, "[Download raw benchmark data (CSV)](benchmarks.csv)")
    println(io)
    for lang in langs
        label = get(LANG_LABELS, lang, lang)
        times = get(benchmarks, lang, Dict{String, Float64}())
        isempty(times) && continue
        ver = get(versions, lang, "")
        heading = isempty(ver) ? "## $label" : "## $label ($ver)"
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
cpu_file       = get(ARGS, 3, "gh_action_cpu.txt")

versions = parse_versions(versions_csv)
cpu = isfile(cpu_file) ? strip(read(cpu_file, String)) : ""
make_chart(benchmarks_csv, versions; cpu)

# Copy the CSVs into docs/src/ so they are available for download in the built site
cp(benchmarks_csv, "docs/src/benchmarks.csv"; force=true)
cp(versions_csv, "docs/src/versions.csv"; force=true)

makedocs(
    format = Documenter.HTML(collapselevel = 1),
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
