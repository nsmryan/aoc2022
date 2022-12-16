package require struct::set

set infile input.txt
#set infile example.txt

proc movePast { line str } {
    return [string range $line [expr [string first $str $line] + [string length $str]] end]
}

proc parseLine { line } {
    regexp {Sensor at x=(-?\d*), y=(-?\d*): closest beacon is at x=(-?\d*), y=(-?\d*)} $line matched x y bx by
    return [list $x $y $bx $by]
}

proc readInput { infile } {
    foreach line [split [read [open $infile r]] \n] {
        if { $line == "" } {
            continue
        }
        lappend positions [parseLine $line]
    }
    return $positions
}


proc distance { x0 y0 x1 y1 } {
    return [expr abs($x0 - $x1) + abs($y0 - $y1)]
}

proc solve { infile } {
    set ytarget 2000000
    foreach pair [readInput $infile] {
        lassign $pair x y bx by
        set dist [distance $x $y $bx $by]
        
        set ydist [expr abs($ytarget - $y)]
        if { $ydist <= $dist } {
            puts $dist
            set yremain [expr $dist - $ydist]
            set xleft [expr $x - $yremain]
            set xright [expr $x + $yremain]
            puts "$xleft $xright"

            lappend points [list start $xleft]
            lappend points [list end $xright]
        }
    }
    puts $points
    set points [lsort -increasing -integer -index 1 $points]
    puts $points
    set count 0
    foreach point $points {
        lassign $point case x
        if { $case == "start" } {
            if { $count == 0 } {
                set leftmost $x
            }
            incr count
        } else {
            incr count -1
            if { $count == 0 } {
                incr total [expr $x - $leftmost]
            }
        }
    }
    return $total
}

puts "Part 1: [solve $infile]"

# TODO for each position:
# get manhatten distance
# check if y axis is within distance
# get range in x, given distance in y, that are set.
# add to a set of visible tiles, or a set of ranges if this is too large.

