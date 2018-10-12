function sum(x0, y0, z0, x1, y1, z1)
	return x0+x1, y0+y1, z0+z1
end

function diff(x0, y0, z0, x1, y1, z1)
	return x0-x1, y0-y1, z0-z1
end

function dot(x0, y0, z0, x1, y1, z1)
	return x0*x1 + y0*y1 + z0*z1
end

function length(x, y, z)
	return sqrt(x^2 + y^2 + z^2)
end

function normalize(x, y, z)
	local l = length(x, y, z)
	return x / l, y / l, z / l
end

function len_square(x0, y0, z0)
	return x^2 + y^2 + z^2
end

function cross(x0, y0, z0, x1, y1, z1)
	return y0*z1-z0*y1, z0*x1-x0*z1, x0*y1-y0*x1
end

function normal(x, y, z)
	local x0, y0, z0 = unpack(x)
	local x1, y1, z1 = unpack(y)
	local x2, y2, z2 = unpack(z)
	
	return normalize(cross(x0 - x1, y0 - y1, z0 - z1, x0 - x2, y0 - y2, z0 - z2))
end

-- Render pipeline functions
function transform(points, ex, ey, ez, tx, ty, tz)
	local sx, cx, sy, cy, sz, cz =
		sin(ex), cos(ex), 
		sin(ey), cos(ey), 
		sin(ez), cos(ez)

	return function()
		local x, y, z = points()
		if (not x) then return end

		local ycx_zsx, zcx_ysx = y*cx-z*sx, z*cx+y*sx
		local xcy_zcx_ysz_sy = x*cy+zcx_ysx*sy

		return
			cz*xcy_zcx_ysz_sy-ycx_zsx*sz+tx,
			cz*ycx_zsx+xcy_zcx_ysz_sy*sz+ty,
			cy*zcx_ysx-x*sy+tz
	end
end

function project(p)
	local x, y, z = unpack(p)
	return flr(x * 128 / z + 64), flr(y * 128 / z + 64)
end

pattern_table = {
	    8,   520,   522,  2570,  2634,
  	 6730,  6746, 23130, 23134, 23390,
	23391, 24415, 24543, 32735, 32767
}

function light(intensity, table)
	local i = mid(0, intensity, 1) * #table
	local c = flr(i)

	fillp(pattern_table[flr((i - c) * 15)])

	return table[c]
end

function flatten(iter)
	local t, i = {}, 1
	for x, y, z in iter do
		t[i] = {x,y,z}
		i = i + 1
	end
	return t
end

function clip_line(a, b)
	local x0, y0, z0 = unpack(a)
	local x1, y1, z1 = unpack(b)
	local t = (1 - z1) / (z0 - z1)

	return { (x0 - x1) * t + x1, (y0 - y1) * t + y1, 1 }
end

function scissor_tri(each, points, face)
	local a, b, c = unpack(face)
	a, b, c = points[a], points[b], points[c]

	-- Rotate it so all the clipped points are at the end	
	for i=1,2 do
		if a[3] < 1 then
			a, b, c = b, c, a
		elseif c[3] > 1 then
			a, b, c = c, a, b
		end
	end

	--if c[3] > 1 then
		each(a, b, c, unpack(face, 4))
	--elseif b[3] > 1 then
		--local t = clip_line(b, c)
		--each(a, b, t, unpack(face, 4))
		--each(a, t, clip_line(c, a), unpack(face, 4))
	--elseif a[3] > 1 then
		--each(a, clip_line(a, b), clip_line(c, a), unpack(face, 4))
	--end
end
