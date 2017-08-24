commands are read line by line

```[<labelname>:] [<commandname> [<arg1>[,<arg2[…]]]] [; <comment>]```

arguments can be either variables, labels or immediates,<br/>
labels are replaced with immediates which have the line numbers of the labels as
their values<br/>
true/false: boolean (immediate)<br/>
12.6: number (immediate)<br/>
$hello nwae: string (immediate)<br/>
nodolla: either a label is called so (immediate) or it's a variable<br/>
If you want to use : in a string, you need to put it at the beginning of the
line to not treat the left part as label



### Types

Name | Description
----|-------------
e| anything defined
v| any variable
ve| any defined variable
s| string
vs| string variable
n| number
vn| number variable
ui| unsigned integer number
b| bool
vb| bool variable


### Instructions

Name | Parameters | Description
-----|------------|------------
mov | `<v to>, <e from>` | `to <= from`; Copies from into to.
xchg | `<v a>, <v b>` | `a,b <= b,a`; Switches a with b.
getvar | `<vs varname>[, <ve exists>]` | Sets varname to the current variable called <varname> if it's set. If exists is passed, it's set to a bool indicating whether the variable was set.
copytable | `<s target>, <s origin>` | Copies ${origin}.* to ${target}.*.
add | `<vn to>, <n from>` | `to <= to + from`
add | `<vb to>[, <b ba>[, <b bb>[…]]]` | `to <= to ∨ ba ∨ bb ∨ …`; logical or: *to* indicates whether at least one of the arguments is true
add | `<vs to>, <s from>` | `to <= to .. from`; string concatenation
sub | `<vn num>, <n tosub>` | `num <= num - tosub`
sub | `<vs str>, <n start>[, <n end>]` | `str <= str:sub(start, end)`; substring
mul | `<vn to>, <n from>` | `to <= to * from`; multiplication
mul | `<vb to>[, <b ba>[, <b bb>[…]]]` | `to <= to ∧ ba ∧ bb ∧ …`; logical and: *to* indicates whether all of the arguments are true
mul | `<vs str>, <n cnt>` | `str <= str:rep(cnt)`; repeating a string cnt times
div | `<vn num>, <n todiv>` | `num <= num / todiv`; division
inc | `<vn num>` | `num <= num + 1`
dec | `<vn num>` | `num <= num - 1`
neg | `<vn num>` | `num <= -num`; negation
neg | `<vb var>` | `var <= ¬var`; logical not
neg | `<vs str>` | `str <= str:rev()`; reverts a string
inv | `<vn num>` | `num <= 1 / num`
mod | `<vn num>, <n dv>` | `num <= num mod dv`; modulo
jmp | `<ui target>[, <e cond>]` | jump; If *cond* is not *false*, the instruction pointer is set to *target*. To disallow infinite loops, the program is interrupted after changing it, mods may have different heuristics about restarting it then.
call | `<ui target>[, <e cond>]` | same as pushing the current instruction pointer and then jumping (see jmp); used to execute subroutines
ret | no arguments | pop some unsigned integer, then jump there; used to exit subroutines
push | `<e a>[, <e b>[, <e c>[…]]]` | put values onto the stack; from left to right
pop | `<v a>[, <v b>[, <v c>[…]]]` | takes values from the stack and sets the passed variables to them; the last variable must be a defined one; from left to right
equal | `<v a>, <e b>` | `a <= (a = b)`; equality
less | `<vn a>, <n b>` | `a <= (a < b)`; after executing, a is a bool
less | `<vs a>, <s b>` | `a <= (a < b)`; less also works for strings, it compares characters from left to right, see man ASCII for the order
greater | `<v a>, <e b>` | executes less b,a
usleep | `<n t>` | aborts the program for at least ⌊max{0, t}⌋ microseconds
sleep | `<n t>` | executes usleep with t * 1000000 as argument
get_us_time | `<v to>` | stores current time in microsecond precision into *to*; can be used to measure time differences
tostring | `<v var>` | Sets *var* to a string representing its value; if it's not defined, it's set to `$nil`, if it's a boolean, it's set to `$true` or `$false`
tonumber | `<v var>` | Sets *var* to a number representing its value
toboolean | `<v var>` | If *var* is `false` or not defined, it's set to `false`, else it's set to `true`.
print | `<e a>[, <e b>[, <e c>[…]]]` | adds variables to the log, seperated by \t (tab), \n (newline) is added at the end
flush | no arguments | Output the log, what exactly happens should vary for every mod.

Note to Developers: Do not edit the instructions manually here in the Readme, do changes in util/standartbefehlssatz_doc.lua and execute it.




How mods can use this mod:

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
	thread:suscitate()
	mykeepalive(thread)
end

mystart(parsed_code)

local function mykeepalive(thread)
	if not thread.stopped then
		return
	end
	thread:try_rebirth()
	minetest.after(0.1, function()
		mykeepalive()
	end)
end
```


TODO:
* add string. instructions
* security: test table copy functions
* update README
