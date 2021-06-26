using Conda, Pkg

const condapkgs = [
	"transformers",
	"emoji",
	"sentencepiece"
]

function build()
	Conda.add_channel("conda-forge")
	foreach(Conda.add, condapkgs)
	ENV["PYTHON"] = joinpath(Conda.PYTHONDIR, "python")
	Pkg.build("PyCall")
end

build()
