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
end

function setmodel!(modelname::String)
	global model = transformers.AutoModel.from_pretrained(modelname)
end

function settokenizer!(modelname::String)
	global tokenizer = transformers.AutoTokenizer.from_pretrained(modelname, normalized=true)
end

function encode(tweet::String)
	tokenizer.encode(tweet)
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
	cls_vecs = model(tensorbatch)["last_hidden_state"] .|> first
	return map(vec -> vec.tolist(), cls_vecs)
end

end
