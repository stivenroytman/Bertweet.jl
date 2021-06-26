module Bertweet

using PyCall

function __init__()
	py"""
	import emoji
	import transformers
	import torch
	"""
	global transformers = py"transformers"
	global model = transformers.AutoModel.from_pretrained("vinai/bertweet-base")
	global tokenizer = transformers.AutoTokenizer.from_pretrained("vinai/bertweet-base", normalized=true)
	global torch = py"torch"
	global demojize = py"emoji.demojize"
end

function setmodel!(modelname::String)
	global model = transformers.AutoModel.from_pretrained(modelname)
end

function settokenizer!(modelname::String)
	global tokenizer = transformers.AutoTokenizer.from_pretrained(modelname, normalized=true)
end

function encode(tweet::String)
	rawtweet = demojize(tweet)
	while occursin("::", rawtweet)
		rawtweet = replace(rawtweet, "::" => ":")
	end
	tokenizer.encode(rawtweet)
end

function pad!(tokenvec::Vector{Int}; maxsize::Int)
	while length(tokenvec) < maxsize
		push!(tokenvec, 1)
	end
end

function batchpad!(tokenbatch::Vector{Vector{Int}})
	pad_to = maximum(length.(tokenbatch))
	foreach(tokenbatch) do tokenvec
		pad!(tokenvec; maxsize=pad_to)
	end
end

function embed(tokenbatch::Vector{Vector{Int}})
	batchpad!(tokenbatch)
	tensorbatch = torch.tensor(tokenbatch)
	output = model(tensorbatch)
	pydecref(tensorbatch)
	cls_vecs = output["last_hidden_state"] .|> first
	embeddings = map(vec -> vec.tolist(), cls_vecs)
	output |> values .|> pydecref
	GC.gc(true)
	torch.cuda.empty_cache()
	return embeddings
end

end
