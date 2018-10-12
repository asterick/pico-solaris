function sorter()
	local top = {}

	return {
		insert = function(cb, score, ...)
			local item = {...}
			local function insert(node)
				if (not node.item) then
					node.cb, node.item, node.score, node.parent, node.left, node.right = cb, item, score, nodes, {}, {}
				else
					insert(score > node.score and node.left or node.right)
				end
			end
			insert(top)
		end,
		iterate = function(each)
			local function iterate(node)
				if not node.item then
					return
				end
				iterate(node.left)
				node.cb(unpack(node.item))
				iterate(node.right)
			end
			iterate(top)
		end
	}
end
