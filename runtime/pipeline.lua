pattern_table = {
	    8,   520,   522,  2570,  2634,
  	 6730,  6746, 23130, 23134, 23390,
	23391, 24415, 24543, 32735, 32767
}

-- Render pipeline functions
function rotate(ex, ey, ez)
	local sx, cx, sy, cy, sz, cz =
		sin(ex), cos(ex), 
		sin(ey), cos(ey), 
		sin(ez), cos(ez)

	return function(x, y, z)
		local ycx_zsx, zcx_ysx = y*cx-z*sx, z*cx+y*sx
		local xcy_zcx_ysz_sy = x*cy+zcx_ysx*sy

		return cz*xcy_zcx_ysz_sy-ycx_zsx*sz,
			   cz*ycx_zsx+xcy_zcx_ysz_sy*sz,
			   cy*zcx_ysx-x*sy
	end
end

function translate(tx, ty, tz)
	return function(x, y, z)
		return x+tx, y+ty, z+tz
	end
end

function scale(sx, sy, sz)
	return function(x, y, z)
		return x*sx, y*sy, z*sz
	end
end

-- Create a lazy transformed vector (cached)
function vectors(points, ...)
	local function chain(top, next, ...)
		if next then 
			local tail = chain(next, ...)
			return function (...)
				return tail(top(...))
			end
		else
			return function (...)
				return top(...)
			end
		end
	end

	local transform = chain(...)

	return setmetatable({}, { 
		__index = function (table, key)
			local out = { transform(unpack(points[key])) }
			table[key] = out
			return out
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
	local x0, y0, z0 = unpack(a)
	local x1, y1, z1 = unpack(b)
	local t = (1 - z1) / (z0 - z1)

	return { (x0 - x1) * t + x1, (y0 - y1) * t + y1, 1 }
end

function scissor(next, a, b, c, ...)
	-- Rotate it so all the clipped points are at the end	
	while a[3] < b[3] or a[3] < c[3] do
		a, b, c = b, c, a
	end

	-- Is partially in view
	if a[3] > 1 then
		local clip_b, clip_c = b[3] < 1, c[3] < 1

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

function strips(next, list, points, ...)
	for strip in all(list) do
		local b, c, a = points[strip[1]], points[strip[2]]

		for i = 3, #strip do
			a, b, c = b, c, points[strip[i]]

			if i % 2 == 0 then 
				next(a, b, c, ...)
			else
				next(a, c, b, ...)
			end
		end
	end
end

function project_point(x, y, z)
	return flr(x * 128 / z + 64), flr(y * 128 / z + 64)
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
