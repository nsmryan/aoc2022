package require struct::prioqueue
package require struct::set

set input [read [open input.txt r]]
#set input [read [open example.txt r]]

binary scan a c aValue
binary scan z c zValue

set width [string length [lindex $input 0]]
set height [llength $input]

set y 0
foreach line $input {
    for { set x 0 } { $x < [string length $line] } { incr x } {
        set chr [string index $line $x]
        if { $chr == "S" } {
            set startPos $x,$y
            set map($x,$y) 0
        } elseif { $chr == "E" } {
            set endPos $x,$y
            set map($x,$y) [expr $zValue - $aValue]
        } else {
            binary scan $chr c chr
            set chr [expr $chr - $aValue]
            set map($x,$y) $chr
        }
    }
    incr y
}

proc validChange { height otherHeight } {
    return [expr (($height + 1) == $otherHeight) || ($height >= $otherHeight)]
}

proc inBounds { pos } {
	global map width height
    lassign [split $pos ,] x y
	return [expr $x >= 0 && $y >= 0 && $x < $width && $y < $height]
}

proc getNextPos { pos } {
    global map

    set height $map($pos)
    lassign [split $pos ,] x y

    set nextList [list]
	set left [expr $x - 1],$y
	set right [expr $x + 1],$y
	set up $x,[expr $y - 1]
	set down $x,[expr $y + 1]
    if { [inBounds $left] && [validChange $height $map($left) ] } {
		lappend nextList $left
    }
    if { [inBounds $right] && [validChange $height $map($right) ] } {
		lappend nextList $right
    }
    if { [inBounds $up] && [validChange $height $map($up) ] } {
		lappend nextList $up
    }
    if { [inBounds $down] && [validChange $height $map($down) ] } {
		lappend nextList $down
    }

    return $nextList
}

proc distance { traveled pos target } {
    global map
	lassign [split $target ,] xEnd yEnd
	lassign [split $pos ,] x y
    return [expr $traveled + abs($x - $xEnd) + abs($y - $yEnd)]
}

set id 0
set invalid [list]
proc solve { start end } {
	global id invalid

	if { [struct::set contains invalid $start] } {
		puts invalid
		return
	}

	set q queue$id
	struct::prioqueue -integer $q

	set visited [list]
	set pos($id) $start
	set dist($id) 0
	set path($id) [list $start]
	struct::set include visited $start
	$q put $id 0

	puts "Starting at $start"
	while { [$q size] > 0 } {
		set shortest [$q get]

		foreach nextPos [getNextPos $pos($shortest)] {
			if { $nextPos == $end } {
				lappend path($shortest) $nextPos
				#puts "path $path($shortest)"
				#puts "length [llength $path($shortest)]"
				set total [expr $dist($shortest) + 1]
				#dict set solved $start $total
				#puts "\t$startPos -> $total"
				return $total
			}
			if { ![struct::set contains $visited $nextPos] } {
				incr id
				set dist($id) [expr $dist($shortest) + 1]
				set path($id) $path($shortest)
				lappend path($id) $nextPos
				#puts "$pos($shortest) -> $nextPos [distance $dist($id) $nextPos $end]"
				set pos($id) $nextPos
				$q put $id [expr 10000 - [distance $dist($id) $nextPos $end]]
				struct::set include visited $nextPos
			}
		}
	}
	struct::set union invalid $visited
	#puts "on no!"
	#exit
}

puts "End pos $endPos"
set solutions [list]
for { set y 0 } { $y < $height } { incr y } {
	for { set x 0 } { $x < $width } { incr x } {
		if { $map($x,$y) == 0 } {
			incr numStarts
		}
	}
}
puts "num starting locations $numStarts"
for { set y 0 } { $y < $height } { incr y } {
	for { set x 0 } { $x < $width } { incr x } {
		if { $map($x,$y) == 0 } {
			set result [solve $x,$y $endPos]
			if { $result != "" } {
				lappend solutions $result
			}
		}
	}
}
puts $solutions
set results [lsort -decreasing $solutions]
puts $results
puts "Part 1: [lindex $results end]"