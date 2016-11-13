local WNOA = "wrong number of arguments"
local UAT = "unsupported argument type"
local SE = "error with cmd-cmd executing: "

local s
s = {
	mov = function(params, faden)
		if #params ~= 2 then
			return false, WNOA
		end
		return true, params[2]
	end,

	add = function(params)
		if #params ~= 2 then
			return false, WNOA
		end
		local p1,p2 = unpack(params)
		local t1 = type(p1)
		local t2 = type(p2)
		if t1 ~= t2 then
			return false, "different argument types"
		end

		if t1 == "number" then
			return true, p1 + p2
		end
		if t1 == "string" then
			return true, p1 .. p2
		end
		return false, UAT
	end,

	jmp = function(params, faden)
		if #params ~= 1 then
			return false, WNOA
		end
		local p = params[1]
		if type(p) ~= "number" then
			return false, UAT
		end
		if p < 1
		or p%1 ~= 0
		or p > #faden.liste + 1 then
			return false, "jump target out of range"
		end
		faden.ip = p-1
		if not s.sleep({0}, faden) then
			error(SE)
		end
		return true
	end,

	jif = function(params, faden)
		if #params ~= 2 then
			return false, WNOA
		end
		if params[1] then
			local jmpd,msg = s.jmp({params[2]}, faden)
			if not jmpd then
				return false, SE .. msg
			end
		end
		return true
	end,

	push = function(params, faden)
		local pc = #params
		if pc == 0 then
			return false, WNOA
		end
		for i = 1,pc do
			faden.stack[faden.sp] = params[i]
			faden.sp = faden.sp-1
		end
		if faden.sp < 0 then
			return false, "stack overflow"
		end
		return true
	end,

	pop = function(params, faden)
		local pc = #params
		if pc == 0 then
			return false, WNOA
		end
		local rt = {}
		for i = 1,pc do
			faden.sp = faden.sp+1
			rt[i] = faden.stack[faden.sp]
		end
		if faden.sp > faden.sb then
			return false, "stack underflow"
		end
		return true, rt
	end,

	equal = function(params, faden)
		if #params ~= 2 then
			return false, WNOA
		end
		return true, params[1] == params[2]
	end,

	less = function(params, faden)
		if #params ~= 2 then
			return false, WNOA
		end
		local t1 = type(p1)
		local t2 = type(p2)
		if t1 ~= t2 then
			return false, "different argument types"
		end
		if t1 ~= "number"
		and t1 ~= "string" then
			return false, UAT
		end
		return true, params[1] < params[2]
	end,

	sleep = function(params, faden)
		if #params ~= 1 then
			return false, WNOA
		end
		local p = params[1]
		if type(p) ~= "number" then
			return false, UAT
		end
		faden.rebirth = minetest.get_gametime() + p
		faden:stop()
		return true
	end,

	flush = function(params, faden)
		return faden:flush(params)
	end,
}
return s
