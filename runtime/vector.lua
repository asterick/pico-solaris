VERTEX_PROTOTYPE = {
	__unm = function(v)
		return v / #v
	end,
	__len = function(v)
		return sqrt(v.x^2 + v.y^2 + v.z^2)
	end,
	__add = function(a,b)
		local x, y, z = unpack_vec(b)
		return vertex(a.x+x, a.y+y, a.z+z)
	end,
	__sub = function(a,b)
		local x, y, z = unpack_vec(b)
		return vertex(a.x-x, a.y-y, a.z-z)
	end,
	__mul = function(a,b)
		local x, y, z = unpack_vec(b)
		return vertex(a.x*x, a.y*y, a.z*z)
	end,
	__div = function(a,b)
		local x, y, z = unpack_vec(b)
		return vertex(a.x/x, a.y/y, a.z/z)
	end,
	__concat = function(a,b)
		return (a.x*b.x + a.y*b.y + a.z*b.z)
	end,
	__pow = function(a,b)
		local x0, y0, z0 = unpack_vec(a)
		local x1, y1, z1 = unpack_vec(b)
		return vertex(y0*z1-z0*y1, z0*x1-x0*z1, x0*y1-y0*x1)
	end
}

function unpack_vec(a)
	if type(a) == 'number' then return a, a, a end
	return a.x, a.y, a.z
end

function vertex(x, y, z)
	return setmetatable({x=x,y=y,z=z}, VERTEX_PROTOTYPE)
end

function normal(a, b, c)
	return -((a - b) ^ (a - c));
end
