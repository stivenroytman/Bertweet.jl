module Bertweet

using PyCall

function __init__()
	py"""
	import emoji
	import transformers
	"""
	global transformers = py"transformers"
end

end
