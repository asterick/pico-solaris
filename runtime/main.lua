function _init()
	local output = inflate(0)
	for i, b in pairs(output) do
		poke(i, b)
		--print (i .. " " .. b)
	end
	print (#output)

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

function update()
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
	local rot = rotate(rotation)
	local points = vertexs(
		cube_points,
		
		function(p)
			return rot(p * 0.2 + position) + vertex(0, 0, 25)
		end
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

function gen_material(t)
	local color = t[#t]
	for i = #t, 1, -1 do
		color, t[i] = t[i], t[i] + color * 0x10
	end
	return t
end

function draw()
	local scene = sorter()
	cls()

	local blue_dither = gen_material({ 0x0, 0x1, 0xD })
	local dither_gradient = gen_material({ 0x0, 0x1, 0x5, 0x6, 0x7 })
	local wacky_dither = gen_material({ 0x0, 0x1, 0x2, 0x3, 0x4, 0x5, 0x6, 0x7, 0x8, 0x9 })

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
