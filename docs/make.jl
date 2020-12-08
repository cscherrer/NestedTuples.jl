using NestedTuples
using Documenter

makedocs(;
    modules=[NestedTuples],
    authors="Chad Scherrer <chad.scherrer@gmail.com> and contributors",
    repo="https://github.com/cscherrer/NestedTuples.jl/blob/{commit}{path}#L{line}",
    sitename="NestedTuples.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://cscherrer.github.io/NestedTuples.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/cscherrer/NestedTuples.jl",
)
