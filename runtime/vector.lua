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
