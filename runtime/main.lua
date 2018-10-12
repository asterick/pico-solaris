function _init()
	for i, b in pairs(inflate(0)) do
		poke(i, b)
	end

	cube_points = {
		{-6,-6,-6},
		{ 6,-6,-6},
		{ 6, 6,-6},
		{-6, 6,-6},
		{-6,-6, 6},
		{ 6,-6, 6},
		{ 6, 6, 6},
		{-6, 6, 6}
	}
	cube_faces = {
		{1,3,2,1},
		{1,4,3,1},
		{5,6,7,2},
		{5,7,8,2},
		{1,5,8,3},
		{1,8,4,3},
		{6,2,7,4},
		{2,3,7,4},
		{1,2,5,5},
		{2,6,5,5},
		{3,4,7,6},
		{4,8,7,6}
	}

	xr, yr, zr = 0, 0, 0
end

function _update()
	xr = xr +  7/1024
	yr = yr + 13/1024
	zr = zr + 17/1024
end

dither_gradient = {0x10, 0x51, 0x65, 0x76, 0x77}

function render_tri(a, b, c, i)
	-- Project
	local xa, ya = project(a)
	local xb, yb = project(b)
	local xc, yc = project(c)

	-- Backface
	if (xa-xb)*(yc-yb) > (xc-xb)*(ya-yb) then
		return
	end

	-- Light and draw
	local intensity = dot(0,0,1,normal(a,b,c))

	local color = light(intensity, dither_gradient)
	triangle(color, xa, ya, xb, yb, xc, yc)		
end

function _draw()
	cls()

	local points = all(cube_points)
	points = map(points, unpack)
	points = transform(points, xr, yr, ze, 0, 0, -25)
	points = flatten(points)

	local scene = sorter()

	local function add_face(a, b, c, ...)
		scene.insert(render_tri, a[3] + b[3] + c[3], a, b, c, ...)
	end

	-- This will be replaced
	for face in all(cube_faces) do
		fcs = scissor_tri(add_face, points, face)
	end

	scene.iterate()
end
