local types = {
	{"e", "anything defined"},
	{"v", "any variable"},
	{"ve", "any defined variable"},
	{"s", "string"},
	{"vs", "string variable"},
	{"n", "number"},
	{"vn", "number variable"},
	{"ui", "unsigned integer number"},
	{"b", "bool"},
	{"vb", "bool variable"}
}

local instr = {
	{"mov", "<v to>, <e from>", "`to <= from`; Copies from into to."},
	{"xchg", "<v a>, <v b>", "`a,b <= b,a`; Switches a with b."},
	{"getvar", "<vs varname>[, <ve exists>]", "Sets varname to the current variable called <varname> if it's set. If exists is passed, it's set to a bool indicating whether the variable was set."},
	{"copytable", "<s target>, <s origin>", "Copies ${origin}.* to ${target}.*."},
	{"add", "<vn to>, <n from>", "`to <= to + from`"},
	{"add", "<vb to>[, <b ba>[, <b bb>[…]]]", "`to <= to ∨ ba ∨ bb ∨ …`; logical or: *to* indicates whether at least one of the arguments is true"},
	{"add", "<vs to>, <s from>", "`to <= to .. from`; string concatenation"},
	{"sub", "<vn num>, <n tosub>", "`num <= num - tosub`"},
	{"sub", "<vs str>, <n start>[, <n end>]", "`str <= str:sub(start, end)`; substring"},
	{"mul", "<vn to>, <n from>", "`to <= to * from`; multiplication"},
	{"mul", "<vb to>[, <b ba>[, <b bb>[…]]]", "`to <= to ∧ ba ∧ bb ∧ …`; logical and: *to* indicates whether all of the arguments are true"},
	{"mul", "<vs str>, <n cnt>", "`str <= str:rep(cnt)`; repeating a string cnt times"},
	{"div", "<vn num>, <n todiv>", "`num <= num / todiv`; division"},
	{"inc", "<vn num>", "`num <= num + 1`"},
	{"dec", "<vn num>", "`num <= num - 1`"},
	{"neg", "<vn num>", "`num <= -num`; negation"},
	{"neg", "<vb var>", "`var <= ¬var`; logical not"},
	{"neg", "<vs str>", "`str <= str:rev()`; reverts a string"},
	{"inv", "<vn num>", "`num <= 1 / num`"},
	{"mod", "<vn num>, <n dv>", "`num <= num mod dv`; modulo"},
	{"jmp", "<ui target>[, <e cond>]", "jump; If *cond* is not *false*, the instruction pointer is set to *target*. To disallow infinite loops, the program is interrupted after changing it, mods may have different heuristics about restarting it then."},
	{"call", "<ui target>[, <e cond>]", "same as pushing the current instruction pointer and then jumping (see jmp); used to execute subroutines"},
	{"ret", "", "pop some unsigned integer, then jump there; used to exit subroutines"},
	{"push", "<e a>[, <e b>[, <e c>[…]]]", "put values onto the stack; from left to right"},
	{"pop", "<v a>[, <v b>[, <v c>[…]]]", "takes values from the stack and sets the passed variables to them; the last variable must be a defined one; from left to right"},
	{"equal", "<v a>, <e b>", "`a <= (a = b)`; equality"},
	{"less", "<vn a>, <n b>", "`a <= (a < b)`; after executing, a is a bool"},
	{"less", "<vs a>, <s b>", "`a <= (a < b)`; less also works for strings, it compares characters from left to right, see man ASCII for the order"},
	{"greater", "<v a>, <e b>", "executes less b,a"},
	{"usleep", "<n t>", "aborts the program for at least ⌊max{0, t}⌋ microseconds"},
	{"sleep", "<n t>", "executes usleep with t * 1000000 as argument"},
	{"get_us_time", "<v to>", "stores current time in microsecond precision into *to*; can be used to measure time differences"},
	{"tostring", "<v var>", "Sets *var* to a string representing its value; if it's not defined, it's set to `$nil`, if it's a boolean, it's set to `$true` or `$false`"},
	{"tonumber", "<v var>", "Sets *var* to a number representing its value"},
	{"toboolean", "<v var>", "If *var* is `false` or not defined, it's set to `false`, else it's set to `true`."},
	{"print", "<e a>[, <e b>[, <e c>[…]]]", "adds variables to the log, seperated by \\t (tab), \\n (newline) is added at the end"},
	{"flush", "", "Output the log, what exactly happens should vary for every mod."},
}

--[[
local mbl = 0
local mal = 0
for i = 1,#instr do
	local bef = instr[i]
	mbl = math.max(#bef[1], mbl)
	mal = math.max(#bef[2], mal)
end--]]

local o = "### Types\n\n" ..
	"Name | Description\n" ..
	"----|-------------\n"
for i = 1,#types do
	local t = types[i]
	o = o .. t[1] .. (" "):rep(1 - #t[1]) .. "| " .. t[2] .. "\n"
end

o = o .. "\n\n### Instructions\n\n" ..
	"Name | Parameters | Description\n" ..
	"-----|------------|------------\n"
for i = 1,#instr do
	i = instr[i]
	if i[2] ~= "" then
		i[2] = "`" .. i[2] .. "`"
	else
		i[2] = "no arguments"
	end
	o = o .. i[1] .. " | " .. i[2] .. " | " .. i[3] .. "\n"
end

o = o ..
	"\n<!-- Note to Developers: Do not edit the instructions manually " ..
	"here in the Readme, do changes in util/standartbefehlssatz_doc.lua and " ..
	"execute it. -->\n"

io.write(o)
io.flush()
