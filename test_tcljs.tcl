# test suite for TclJS
# This file is designed so it can also run in a tclsh. Some JavaScript goodies,
# like 1/0, sqrt(-1) were excluded from the tests.
# [clock format 0] was excluded because the timezone string differed.

set vars [info vars] ;# for later cleanup
set version 0.5.3
set total   0
set passed  0
set fail    0
puts "------------------------ [info script] patchlevel: [info patchlevel]"

proc e.g. {cmd -> expected} {
    incr ::total
    incr ::fail ;# to also count exceptions
    set res [uplevel 1 $cmd]
    if ![string equal $res $expected] {
    #if {$res != $expected} {} #should work, but wouldn't
	puts "**** $cmd -> $res, expected: $expected"
    } else {incr ::passed; incr ::fail -1}
}

# e.g. {exec echo hello} -> hello ;# needs blocking exec

e.g. {append new hello} -> hello
e.g. {set x foo}        -> foo
e.g. {append x bar}     -> foobar

proc sum args {expr [join $args +]}
e.g. {sum 1 2 3} -> 6
#native sum2 {function (interp, args) {return eval(args.join("+"));}}
#e.g. {sum2 2 3 4} -> 9

e.g. {concat {a b} {c d}} -> {a b c d}

e.g. {set d [dict create a 1 b 2 c 3]} -> {a 1 b 2 c 3}
e.g. {dict exists $d c} -> 1
e.g. {dict exists $d x} -> 0
e.g. {dict get $d b}    -> 2
e.g. {dict keys $d}     -> {a b c}
e.g. {dict set d b 5}   -> {a 1 b 5 c 3}
e.g. {dict set d x 7}   -> {a 1 b 5 c 3 x 7}
e.g. {dict unset d b}   -> {a 1 c 3 x 7}
e.g. {dict unset d x}   -> {a 1 c 3}
e.g. {dict unset d nix} -> {a 1 c 3}
e.g. {dict set dx a 1}  -> {a 1} ;# create new dict if not exists

e.g. {set home [file dirname [pwd]]; list} -> {}
e.g. {string equal [set env(HOME)] $home}   -> 1
e.g. {string equal [set ::env(HOME)] $home} -> 1

e.g. {expr 6*7}         -> 42
e.g. {expr {6 * 7 + 1}} -> 43
e.g. {set x 43}         -> 43
e.g. {expr {$x-1}}      -> 42
e.g. {expr $x-1}        -> 42
if ![info exists auto_path] { ;#these tests are not for a real tclsh
    e.g. {clock format 0} -> {Thu Jan 01 1970 01:00:00 GMT+0100 (CET)}
    e.g. {set i [expr 1/0]} -> Infinity
    e.g. {expr $i==$i+42}   -> 1
    e.g. {set n [expr sqrt(-1)]} -> NaN
    e.g. {expr $n == $n} -> 0
    e.g. {expr $n==$n}   -> 0
    e.g. {expr $n!=$n}   -> 1
    e.g. {info patchlevel} -> $version
    e.g. {set vars}      -> {argc argv0 argv errorInfo} ;# many more in real Tcl

}
e.g. {expr 0xFF}               -> 255
e.g. {set x 0xFF; expr {$x+0}} -> 255
e.g. {expr 0376}               -> 254
e.g. {set x 0375; expr $x}     -> 253
e.g. {expr {$x}}   -> 253
e.g. {expr 6 * 7}  -> 42
e.g. {expr 1 == 2} -> 0
e.g. {expr 1 < 2}  -> 1
e.g. {expr !0}     -> 1
e.g. {expr !42}    -> 0
e.g. {set x 3}     -> 3
e.g. {expr $x+1}   -> 4
e.g. {expr {$x+1}} -> 4
e.g. {set x a; set y b; expr {$x == $y}} -> 0
e.g. {expr {$x != $y}} -> 1

set forres ""
e.g. {for {set i 0} {$i < 5} {incr i} {append forres $i}; set forres} -> 01234
e.g. {foreach i {a b c d e} {append foreachres $i}; set foreachres}   -> abcde

e.g. {format %x 255} -> ff
e.g. {format %X 254} -> FE

e.g. {set x 41}  -> 41
e.g. {incr x}    -> 42
e.g. {incr x 2}  -> 44
e.g. {incr x -3} -> 41

e.g. {info args e.g.} -> {cmd -> expected}
e.g. {unset -nocomplain foo} -> {}
e.g. {info exists foo} -> 0
e.g. {set foo 42}      -> 42
e.g. {info exists foo} -> 1
e.g. {info level}      -> 0 ;# e.g. runs the command one level up
e.g. {proc f x {set y 0; info vars}} -> ""
e.g. {f 41}            -> {x y}
set tmp [f 40]; e.g. {lappend tmp z} -> {x y z}
e.g. {info args f}      -> x
e.g. {info body f}      -> {set y 0; info vars}
e.g. {info bod f}       -> {set y 0; info vars}

e.g. {join {a b c}}     -> {a b c}
e.g. {join {a b c} +}   -> {a+b+c}
e.g. {join {a {b c} d}} -> {a b c d}
e.g. {join {a b c} ""}  -> abc

e.g. {set x {a b c}}      -> {a b c}
e.g. {set x [list a b c]} -> {a b c}
e.g. {lappend x}          -> {a b c}
e.g. {lappend x {}}       -> {a b c {}}
e.g. {set x}              -> {a b c {}}
e.g. {lset x 3 e}         -> {a b c e}
e.g. {llength $x}         -> 4
e.g. {lindex $x 2}        -> c
e.g. {lrange $x 1 2}      -> {b c}
e.g. {lreverse {a b c}}   -> {c b a}
e.g. {lsearch $x b}       -> 1
e.g. {lsearch $x y}       -> -1
e.g. {lsort {z x y}}      -> {x y z}

e.g. {regexp {X[ABC]Y} XAY}    -> 1
e.g. {regexp {X[ABC]Y} XDY}    -> 0
e.g. {regsub {[A-C]+} uBAAD x} -> uxD 

e.g. {split "a b  c d"}     -> {a b {} c d}
e.g. {split " a b  c d"}     -> {{} a b {} c d}
e.g. {split "a b  c d "}     -> {a b {} c d {}}
e.g. {split usr/local/bin /} -> {usr local bin}
e.g. {split /usr/local/bin /} -> {{} usr local bin}
e.g. {split abc ""}          -> {a b c}

e.g. {string compare a b}     -> -1
e.g. {string compare b a}     -> 1
e.g. {string compare b b}     -> 0
e.g. {string equal foo foo}   -> 1
e.g. {string equal foo bar}   -> 0
e.g. {string index abcde 2}   -> c
e.g. {string length ""}       -> 0
e.g. {string length foo}      -> 3
e.g. {string range hello 1 3} -> ell
e.g. {string tolower Tcl}     -> tcl
e.g. {string toupper Tcl}     -> TCL
e.g. {string trim " foo "}    -> foo

#e.g. {set x a.\x62.c} -> a.b.c ;# severe malfunction, breaks test suite operation :(

puts "total $total tests, passed $passed, failed $fail"
#----------- clean up variables used in tests
foreach var [info vars] {
    set pos [lsearch $vars $var] ;# expr can't substitute commands yet
    set neq [string compare $var vars]
    if {$var != "vars" && $pos < 0} {unset $var}
}
unset vars var pos neq
puts "vars now: [info vars]"
puts "[llength [info commands]] commands implemented"
