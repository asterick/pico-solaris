function sorter()
	local root = {}

	local function walk(node)
		if node then
			walk(node[true])
			node.cb(unpack(node))
			walk(node[false])
		end
	end

	return {
		insert = function(cb, score, ...)
			local node, target, item = root, "first", { cb = cb, score = score, ... }

			while node[target] do
				node = node[target]
				target = score > node.score
			end

			node[target] = item 
		end,

		iterate = function()
			walk(root.first)
		end
	}
end
