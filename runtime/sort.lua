function sorter()
	local top

	return {
		insert = function(cb, score, ...)
			local item = { cb = cb, score = score, ... }

			if not top then top = item; return end

			local node = top

			while true do
				if score > node.score then
					if not node.left then 
						node.left = item 
						return 
					end

					node = node.left
				else
					if not node.right then 
						node.right = item
						return 
					end

					node = node.right
				end
			end
		end,

		iterate = function(each)
			local function iterate(node)
				if not node then return end
				iterate(node.left)
				node.cb(unpack(node))
				iterate(node.right)
			end
			iterate(top)
		end
	}
end
