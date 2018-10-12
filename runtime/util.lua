function unpack(y, i)
	i = i or 1
	local g = y[i]
	if (g) then 
		return g, unpack(y, i + 1)
	end
end

function enumerate(i)
	local idx = 0
	return function()
		idx = idx + 1
		local v = i()
		if (v) then return idx, v end
	end
end

function map(t, transform)
	return function()
		local o = t()
		if (o) then return transform(o) end
	end
end

function join(a, b, ...)
	x = {...}

	for i = 1, #x do
		b = b .. a .. x[i]
	end

	return b
end
