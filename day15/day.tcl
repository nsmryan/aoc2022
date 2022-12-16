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
    return [solveLine [readInput $infile]]
}

proc solveLine { lines } {
    for { set i 0 } { $i < 4000000 } { incr i } {
		set points [list]

		foreach pair $lines {
			lassign $pair x y bx by
			set dist [distance $x $y $bx $by]
			
			set ydist [expr abs($i - $y)]
			if { $ydist <= $dist } {
				set yremain [expr $dist - $ydist]
				set xleft [expr $x - $yremain]
				set xright [expr $x + $yremain]

				if { $xleft > 4000000 || $xright < 0 } {
					continue
				}

				set xleft [expr max($xleft, 0)]
				set xright [expr min($xright, 4000000)]
				lappend points [list 1 $xleft]
				lappend points [list -1 $xright]
			}
		}

		set points [lsort -increasing -integer -index 1 $points]
		#puts $points

        set resultX [checkY $i $points]
        if { $resultX != "" } {
			puts "returning $resultX $i"
            return [list $resultX $i]
        }
        if { $i % 10000 == 0 } {
            puts "up to $i"
        }
    }
    throw INVALIDSOLUTION "No solution found!"
}

proc checkY { ytarget points } {
    set count 0
	set leftmost 0
	set rightmost 0
    foreach point $points {
        lassign $point case x
		if { $case == 1 && $count == 0 } {
			if { ($x - $rightmost) > 1 } {
				return [expr $x - 1]
			}
			set leftmost $x
		}
		incr count $case
		if { $count == 0 } {
			set rightmost $x
			#if { $x > 0 && $x < 4000000 } {
			#	return [expr $x + 1]
			#}
        }
    }
    return ""
}

set result [solve $infile]
puts $result
lassign $result x y
puts "Part 1: [expr $x * 4000000 + $y]"

# TODO for each position:
# get manhatten distance
# check if y axis is within distance
# get range in x, given distance in y, that are set.
# add to a set of visible tiles, or a set of ranges if this is too large.

