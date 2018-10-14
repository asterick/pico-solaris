function _init()
	for i, b in pairs(inflate(0)) do
		poke(i, b)
	end

	cube_points = {
		vertex(-6,-6,-6),
		vertex( 6,-6,-6),
		vertex( 6, 6,-6),
		vertex(-6, 6,-6),
		vertex(-6,-6, 6),
		vertex( 6,-6, 6),
		vertex( 6, 6, 6),
		vertex(-6, 6, 6)
	}

	cube_strips = {
		{ 5, 6, 1, 2, 4, 3, 8, 7 },
		{ 1, 4, 5, 8, 6, 7, 2, 3 }
	}

	rotation = vertex(0,0,0)
end

function _update()
	rotation += vertex(7/1024, 13/1024, 3/1024)
end

function render(a, b, c, gradient)
	-- Project
	local xa, ya = project_point(a)
	local xb, yb = project_point(b)
	local xc, yc = project_point(c)

	-- Backface
	if (xa-xb)*(yc-yb) > (xc-xb)*(ya-yb) then
		-- Light and draw
		local intensity = vertex(0, 0, -1) .. normal(a,b,c)
		local pattern, color = light(intensity, gradient)

		fillp(pattern)
		trifill(xa, ya, xb, yb, xc, yc, color)
	end
end

function cube(scene, position, rotation, gradient)
	-- vertex stage
	local points = vertexs(
		cube_points,
		scale(0.2),
		translate(position),
		rotate(rotation),
		translate(vertex(0, 0, 25))
	);

	-- Geometry stage
	geometry(
		{ cube_strips, points, gradient },
		strips,
		scissor,
		function (next, a, b, c, ...)
			scene.insert(render, a.z + b.z + c.z, a, b, c, ...)
		end
	)
end

function _draw()
	local scene = sorter()
	cls()

	local dither_gradient = { 0x10, 0x51, 0x65, 0x76, 0x77 }
	local blue_dither = { 0x10, 0xD1, 0xDD }
	local wacky_dither = { 0x00, 0x10, 0x21, 0x32, 0x43, 0x54, 0x65, 0x76, 0x87, 0x98, 0x99 }

	cube(scene, vertex( 0,  0,  0),     rotation,    wacky_dither)
	cube(scene, vertex(-1,  0,  0), rotation*0.1,     blue_dither)
	cube(scene, vertex( 0, -2,  0), rotation*0.2,     blue_dither)
	cube(scene, vertex( 0,  0, -3), rotation*0.3,     blue_dither)
	cube(scene, vertex( 0,  0,  4), rotation*0.4, dither_gradient)
	cube(scene, vertex( 0,  5,  0), rotation*0.5, dither_gradient)
	cube(scene, vertex( 6,  0,  0), rotation*0.6, dither_gradient)

	-- Render all the remaining triangles
	scene.iterate()
end
