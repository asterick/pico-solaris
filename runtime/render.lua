function bham(x0, y0, x1, y1)
	local d_x, d_y, delta, t = 
		abs(x1 - x0), 
		abs(y1 - y0), 
		(x0 < x1) and 1 or -1
	t = d_y / 2

	return function ()
		while t > d_y do x0, t = x0 + delta, t - d_y end
		t = t + d_x
		return x0
	end
end

function triangle(color, x0, y0, x1, y1, x2, y2)
	if y1 < y0 then x0, y0, x1, y1 = x1, y1, x0, y0 end
	if y2 < y0 then x0, y0, x2, y2 = x2, y2, x0, y0 end
	if y2 < y1 then x2, y2, x1, y1 = x1, y1, x2, y2 end

	local a, b, c = 
		bham(x0, y0, x1, y1),
		bham(x1, y1, x2, y2),
		bham(x0, y0, x2, y2)

	for y =   y0, y1 do rectfill(a(), y, c(), y, color) end
	for y = 1+y1, y2 do rectfill(b(), y, c(), y, color) end
end

function circle(color, xc, yc, r)
  circfill(xc, yc, r, color)
end
