commands are read line by line

```[<labelname>:] [<commandname> [<arg1>[,<arg2[…]]]] [; <comment>]```

arguments can be either variables, labels or immediates,
labels are replaced with immediates which have the line numbers of the labels as their values
true/false: boolean (immediate)
12.6: number (immediate)
$hello nwae: string (immediate)
nodolla: either a label is called so (immediate) or it's a variable



How to use this mod:

```
local mylog = print

local parsed_code = pdisc.parse(code_text)

local function mystart(parsed_code)
	local thread = pdisc.create_thread(function(thread)
		thread.flush = function(self)
			mylog(self.log)
			self.log = ""
			return true
		end
	end, parsed_code)
	mykeepalive()
end

mystart(parsed_code)

local function mykeepalive()
	thread:suscitate()
	if not thread.stopped then
		return
	end
	thread:try_rebirth()
	minetest.after(0.1, function()
		mykeepalive()
	end)
end
```
