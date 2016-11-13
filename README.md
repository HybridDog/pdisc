commands are read line by line

```[<labelname>:] [<commandname> [<arg1>[,<arg2[…]]]] [; <comment>]```

arguments can be either variables, labels or immediates,
labels are replaced with immediates which have the line numbers of the labels as their values
true/false: boolean (immediate)
12.6: number (immediate)
$hello nwae: string (immediate)
nodolla: either a label is called so (immediate) or it's a variable
