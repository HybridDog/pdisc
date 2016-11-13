local function befehl_ausfuhren(faden)
	local is = faden.is
	local imms = faden.imms
	local vars = faden.vars
	local befehl, args = unpack(faden.liste[faden.ip])
	for i = 1,#is do
		local bfunk = is[i]
		if bfunk then
			local fa = {}
			local ersetzbar = {}
			if args then
				for i = 1,#args do
					local arg = args[i]
					if type(arg) == "number" then
						fa[i] = imms[arg]
					else
						fa[i] = vars[arg]
						ersetzbar[i] = true
					end
				end
			end
			local weiter, ergebnis = bfunk(fa, faden)
			if not weiter then
				return false, "Command " .. befehl .. ": " .. ergebnis
			end
			if ergebnis ~= nil then
				if type(ergebnis) ~= "table" then
					ergebnis = {ergebnis}
				end
				for i,v in pairs(ergebnis) do
					if not ersetzbar[i] then
						return false, "Attempt on changing an immediate"
					end
					vars[args[i]] = v
				end
			end
			faden.ip = faden.ip + 1
			if faden.ip > #faden.liste then
				return false, "Done"
			end
			return true
		end
	end
	return false, 'Unknown command "' .. befehl .. '"'
end

local function programm_ausfuhren(faden)
	local weiter,msg = befehl_ausfuhren(faden)
	if not weiter then
		faden.log = faden.log .. "Aborted: " .. msg .. "\n"
		faden.exit()
		return
	end
	return not faden.stopped and programm_ausfuhren(faden)
end

return function(faden_manip, parsed)
	local faden = {
		log = "",
		ip = 1,
		sp = 50,
		sb = 50,
		stack = {},
		is = {pdisc.standard_befehlssatz},
		suscitate = programm_ausfuhren,
		flush = function(self)
			print(self.log)
			self.log = ""
			return true
		end,
		stop = function(self)
			self.stopped = true
		end,
		continue = function(self)
			self.stopped = false
			self:suscitate()
		end,
		try_rebirth = function(self)
			if minetest.get_gametime() < self.rebirth then
				self:continue()
			end
		end,
		exit = function(self)
			self:flush()
		end,
	}
	if parsed then
		faden.imms = parsed[1]
		faden.liste = parsed[2]
	end
	faden_manip(faden)
	return faden
end
