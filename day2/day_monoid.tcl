set input [read [open input.txt r]]
#set input [list A Y B X C Z]

set values [list X 0 Y 1 Z 2]
set oppValues [list A 0 B 1 C 2]
proc map { a b } { return [expr ($a + 2 * $b + 1) % 3] }
foreach { a b } $input {
    set index [dict get $values $b]
    incr total1 [expr $index + 1 + 3 * [map $index [dict get $oppValues $a]]]
}
puts $total1

proc map2 { a b } { return [expr ($a + $b + 2) % 3] }
foreach { a b } $input {
    set outcome [dict get $values $b]
    set oppIndex [dict get $oppValues $a]
    incr total2 [expr [map2 $oppIndex $outcome] + 1 + 3 * $outcome]
}
puts $total2

proc comment args { }
foreach y [list 0 1 2] {
    foreach x [list 0 1 2] {
        puts "$y $x [map $y $x]"
    }
}
puts ""
foreach y [list 0 1 2] {
    foreach x [list 0 1 2] {
        #puts "$y $x [map [map $x $y] [map $y $x]]"
        puts "$y $x [map2 $y $x]"
    }
}
comment {
}

comment {
part 2 map

     A B C
lose Y X Z
draw X Y Z
win  Y Z X

     A B C
lose 2 0 1
draw 0 1 2
win  1 2 0

  L D W
A 1 0 1
B 0 1 2
C 2 2 0
}


comment {
X 0
Y 1
Z 2

A 0
B 1
C 2

lose 0
draw 1
win 2


XA 1
YA 2
ZA 0

XB 0
YB 1
ZB 2

XC 2
YC 0
ZC 1

part 1 map
  A B C
X 1 0 2
Y 2 1 0
Z 0 2 1
}
