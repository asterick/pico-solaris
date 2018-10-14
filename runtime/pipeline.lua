pattern_table = {
	    8,   520,   522,  2570,  2634,
  	 6730,  6746, 23130, 23134, 23390,
	23391, 24415, 24543, 32735, 32767
}

-- Render pipeline functions
function rotate(e)
	local sx, cx, sy, cy, sz, cz =
		sin(e.x), cos(e.x), 
		sin(e.y), cos(e.y), 
		sin(e.z), cos(e.z)

	return function(p)
		local ycx_zsx, zcx_ysx = p.y*cx-p.z*sx, p.z*cx+p.y*sx
		local xcy_zcx_ysz_sy = p.x*cy+zcx_ysx*sy

		return vertex(cz*xcy_zcx_ysz_sy-ycx_zsx*sz,
			   cz*ycx_zsx+xcy_zcx_ysz_sy*sz,
			   cy*zcx_ysx-p.x*sy)
	end
end

-- Create a lazy transformed vector (cached)
function vertexs(points, ...)
	local transform = {...}

	return setmetatable({}, { 
		__index = function (table, key)
			local point = points[key]
			if points[key] then
				for t in all(transform) do point = t(point) end
			end
			table[key] = point
			return point
		end
	});
end

--- Draw functions
function light(intensity, table)
	local i = mid(0, intensity, 1) * #table
	local c = flr(i)

	return pattern_table[flr((i - c) * 15)], table[c]
end

function clip_line(a, b)
	local t = (1 - b.z) / (a.z - b.z)

	return vertex((a.x - b.x) * t + b.x, (a.y - b.y) * t + b.y, 1)
end

function strips(next, list, points, ...)
	for strip in all(list) do
		local toggle = false
		local b, c, a = points[strip[1]], points[strip[2]]

		for i = 3, #strip do
			toggle, a, b, c = not toggle, b, c, points[strip[i]]

			if toggle then 
				next(b, a, c, ...)
			else
				next(a, b, c, ...)
			end
		end
	end
end

function scissor(next, a, b, c, ...)
	-- Rotate it so all the clipped points are at the end	
	while a.z < b.z or a.z < c.z do
		a, b, c = b, c, a
	end

	-- Is partially in view
	if a.z > 1 then
		local clip_b, clip_c = b.z < 1, c.z < 1

		if clip_b and clip_c then
			local a_b = clip_line(a, b)
			local c_b = clip_line(a, c)

			next(  a, a_b, a_c, ...)
		elseif clip_b then
			local a_b = clip_line(a, b)
			local c_b = clip_line(c, b)

			next(  a, a_b, c_b, ...)
			next(  a, c_b,   c, ...)
		elseif clip_c then
			local a_c = clip_line(a, c)
			local b_c = clip_line(b, c)

			next(  a,   b, b_c, ...)
			next(  a, b_c, a_c, ...)
		else
			next(  a,   b,   c, ...)
		end
	end
end

function project_point(p)
	return flr(p.x * 128 / p.z + 64), flr(p.y * 128 / p.z + 64)
end

function geometry(params, ...)
	local function chain(top, next, ...)
		local tail = next and chain(next, ...)

		return function (...)
			return top(tail, ...)
		end
	end

	local transform = chain(...)

	transform(unpack(params))
end
