function inflate(index)
	local tbits = 0
	local base_tbl, ins_tbl

	local output = {}

	local function bits(n)
		local out = 0
		for i = 0, n-1 do
			if (tbits >= 8) then 
				tbits = 0
				index = index + 1
			end
			out = out + band(peek(index) / 2 ^ tbits, 1) * 2 ^ i
			tbits = tbits + 1
		end
		return out
	end

	local function make_tbl(lens)
		local idx, out = 0, {}
		for b = 1, 16 do
			for c = 1, 288 do
				if lens[c] == b then
					out[b/16+idx] = c - 1
					idx = idx + 1
				end
			end
			idx = idx * 2
		end
		return out
	end

	local function def_tbl(arg)
		local x = {}
		for i = 1, #arg, 2 do
			for k = 1, arg[i] do
				add(x, arg[i+1])
			end
		end
		return make_tbl(x)
	end

	local function get_int(code, width)
		local offset = 0

		for i = 0, code do
			local extra = flr(max(0, i / width - 1))
			if (i == code) then
				return offset + bits(extra)
			end
			offset = offset + 2 ^ extra
		end
	end

	local function get_code(table)
		local code = 0
		for b=1, 16 do
			code = code * 2 + bits(1)
			local out = table[b/16 + code]
			if (out) then 
				return out
			end
		end		
	end

	local function compressed()
		while true do
			local code, length, offs = get_code(base_tbl), 258

			if code <= 255 then	
				add(output, code)
			elseif code == 256 then
				break
			else
				if code < 285 then
					length = get_int(code - 257, 4) + 3
				end

				offs = get_int(get_code(ins_tbl), 2)
				for i = 1, length do
					add(output, output[#output - offs])
				end
			end
		end
	end

	repeat
		local final, method = bits(1), bits(2)

		if method == 1 then
			-- These are special ones
			base_tbl = def_tbl({144, 8, 112, 9, 24, 7, 8, 8})
			ins_tbl = def_tbl({32, 5})
			compressed()
		elseif method == 2 then
			-- Create dynamic table
			local hlit, hdist, hclen = bits(5), bits(5), bits(4)
			local hc_tbl = {}

			-- Create our code length table
			for i=1, 4 + hclen do
				hc_tbl[({ 17, 18, 19, 1, 9, 8, 10, 7, 11, 6, 12, 5, 13, 4, 14, 3, 15, 2, 16 })[i]] = bits(3)
			end

			hc_tbl = make_tbl(hc_tbl)

			local function build(count)
				local out = {}

				while #out < count do
					local code = get_code(hc_tbl)

					if code < 16 then
						add(out, code)
					elseif code == 16 then
						for i = -2, bits(2) do
							add(out, out[#out])
						end
					elseif code == 17 then
						for i = -2, bits(3) do
							add(out, 0)
						end
					else
						for i = -10, bits(7) do 
							add(out, 0) 
						end
					end
				end

				return make_tbl(out)
			end

			base_tbl = build(257 + hlit)
			ins_tbl = build(1 + hdist)
			compressed()
		else
			if (tbits) then
				tbits, index = 0, index + 1
			end
			local len = bits(16) bits(16)
			for i = 1, len do
				add(output, bits(8))
			end
		end
	until final > 0

	return output
end
