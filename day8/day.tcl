set input [read [open input.txt r]]
#set input [read [open example.txt r]]

set width [string length [lindex $input 0]]
set height [llength $input]

set y 0
foreach line $input {
    for { set x 0 } { $x < [string length $line] } { incr x } {
        set map($x,$y) [string index $line $x]
        set visible($x,$y) 0
    }
    incr y
}

proc checkLine { startX startY xOffset yOffset } {
    global map visible

    set x $startX
    set y $startY
    set maxHeight $map($x,$y)

    set visible($x,$y) 1

    incr x $xOffset
    incr y $yOffset

    while { [info exists map($x,$y)] } {
        if { $map($x,$y) > $maxHeight } {
            set visible($x,$y) 1
            set maxHeight $map($x,$y)
        }

        incr x $xOffset
        incr y $yOffset
    }
}

for { set x 0 } { $x < $width } { incr x } {
    checkLine $x 0 0 1
    checkLine [expr $width - 1 - $x] [expr $height - 1] 0 -1
}

for { set y 0 } { $y < $height } { incr y } {
    checkLine 0 $y 1 0
    checkLine [expr $width - 1] [expr $height - 1 - $y] -1 0
}

foreach name [array names map] {
    incr total $visible($name)
}
puts "Part 1: $total"


proc scoreLine { startX startY xOffset yOffset } {
    global map width height
    set x $startX
    set y $startY

    set treeHeight $map($x,$y)

    incr x $xOffset
    incr y $yOffset

    set dist 0
    while { $x >= 0 && $y >= 0 && $x < $width && $y < $height } {
        incr dist
        if { $map($x,$y) >= $treeHeight } {
            break
        }
        incr x $xOffset
        incr y $yOffset
    }

    return $dist
}

set total2 0
for { set y 0 } { $y < $height } { incr y } {
    for { set x 0 } { $x < $width } { incr x } {
        set lineScore [scoreLine $x $y 1 0]
        set lineScore [expr $lineScore * [scoreLine $x $y -1 0]]
        set lineScore [expr $lineScore * [scoreLine $x $y 0 1]]
        set lineScore [expr $lineScore * [scoreLine $x $y 0 -1]]

        set total2 [expr max($total2, $lineScore)]
    }
}
puts "Part 2: $total2"
