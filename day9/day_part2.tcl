package require struct::set

set input [split [read [open input.txt r]] \n]
#set input [split [read [open example.txt r]] \n]
#set input [split [read [open example2.txt r]] \n]

set offsets [list R [list 1 0] L [list -1 0] U [list 0 -1] D [list 0 1]]

set total1 0
set total2 0

for { set i 0 } { $i < 10 } { incr i } {
    set knotsX($i) 0
    set knotsY($i) 0
}

proc distance { x0 y0 x1 y1 } {
    return [expr max(abs($x0 - $x1), abs($y0 - $y1))]
}

proc sign { value } {
    if { $value == 0 } {
        return 0
    } elseif { $value > 0 } {
        return 1
    } else {
        return -1
    }
}

proc printRope { } {
    global knotsX knotsY
    set maxX 5
    set maxY 5
    set current [list]
    for { set i 0 } { $i < 10 } { incr i } {
        dict set current $knotsX($i),$knotsY($i) $i
        #puts "$knotsX($i),$knotsY($i) $i"
        #set maxX [expr max($maxX, $knotsX($i))]
        #set maxY [expr max($maxY, $knotsY($i))]
    }
    for { set y -$maxY } { $y < $maxY } { incr y } {
        for { set x -$maxX } { $x < $maxX } { incr x } {
            if { [dict exists $current $x,$y] } {
                puts -nonewline [dict get $current $x,$y]
            } else {
                puts -nonewline .
            }
        }
        puts ""
    }
    puts "___________________"
}

struct::set include visited (0,0)

foreach line $input {
    if { $line == "" } continue
    lassign $line dir amount


    for { set index 0 } { $index < $amount } { incr index } {
        #printRope
        lassign [dict get $offsets $dir] xOffset yOffset
        for { set i 0 } { $i < 10 } { incr i } {

            incr knotsX($i) $xOffset
            incr knotsY($i) $yOffset

            if { $i > 0 } {
                set lastI [expr $i - 1]
                if { [distance $knotsX($lastI) $knotsY($lastI) $knotsX($i) $knotsY($i)] > 1 } {
                    set txOffset [sign [expr $knotsX($lastI) - $knotsX($i)]]
                    set tyOffset [sign [expr $knotsY($lastI) - $knotsY($i)]]

                    incr knotsX($i) $txOffset
                    incr knotsY($i) $tyOffset

                }
            }

            if { $i != 9 } {
                set nextI [expr $i + 1]
                if { [distance $knotsX($i) $knotsY($i) $knotsX($nextI) $knotsY($nextI)] > 1 } {
                    set xOffset [sign [expr $knotsX($i) - $knotsX($nextI)]]
                    set yOffset [sign [expr $knotsY($i) - $knotsY($nextI)]]
                } else {
                    # no need to continue if distance is not enough to keep moving rope.
                    break
                }
            }
        }
        struct::set include visited ($knotsX(9),$knotsY(9))
    }

}

set total1 [struct::set size $visited]
puts "result $total1"
