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

cube_strips = {
	{ 5, 6, 1, 2, 4, 3, 8, 7 },
	{ 1, 4, 5, 8, 6, 7, 2, 3 }
}

function _init()
	for i, b in pairs(inflate(0)) do
		poke(i, b)
	end

	xr, yr, zr = 0, 0, 0
end

function _update()
	xr = xr +  7/1024
	yr = yr + 13/1024
	zr = zr + 17/1024
end

dither_gradient = { 0x10, 0x51, 0x65, 0x76, 0x77 }

function render(a, b, c)
	-- Project
	local xa, ya = project_point(unpack(a))
	local xb, yb = project_point(unpack(b))
	local xc, yc = project_point(unpack(c))

	-- Backface
	if (xa-xb)*(yc-yb) > (xc-xb)*(ya-yb) then
		-- Light and draw
		local intensity = dot( 0, 0, -1, normal(a,b,c))
		local pattern, color = light(intensity, dither_gradient)

		fillp(pattern)
		trifill(xa, ya, xb, yb, xc, yc, color)
	end
end

function _draw()
	local scene = sorter()
	cls()

	-- Vector stage
	local points = vectors(
		cube_points,
		rotate(xr, yr, ze),
		translate(0, 0, 25)
	);

	-- Geometry stage
	geometry(
		{ cube_strips, points },	
		strips,
		scissor,
		function (next, a, b, c, ...)
			scene.insert(render, a[3] + b[3] + c[3], a, b, c, ...)
		end
	)

	-- Render all the remaining triangles
	scene.iterate()
end
