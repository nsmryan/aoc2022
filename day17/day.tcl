set infile input.txt
#set infile example.txt

proc getJet { } {
    global jetList
    global jetIndex
    set strIndex [expr $jetIndex % [string length $jetList]]
    set jet [string index $jetList $strIndex]
    incr jetIndex
    return $jet
}

proc jetOffset { } {
    set jet [getJet]
    if { $jet == "<" } {
        return -1
    } else {
        return 1
    }
}

proc makeShape { offsets x y } {
    foreach offset $offsets {
        lassign $offset ox oy
        lappend result [list [expr $x + $ox] [expr $y + $oy]]
    }
    return $result
}

proc horiz { x y } { return [makeShape { { 0 0 } { 1 0 } { 2 0 } { 3 0 } } $x $y] }
proc L { x y } { return [makeShape { { 2 0 } { 2 -1 } { 2 -2 } { 1 -2 } { 0 -2 } } $x $y] }
proc line { x y } { return [makeShape { { 0 0 } { 0 -1 } { 0 -2 } { 0 -3 } } $x $y] }
proc block { x y } { return [makeShape { { 0 0 } { 0 -1 } { 1 0 } { 1 -1 } } $x $y] }
proc plus { x y } { return [makeShape { { 1 0 } { 0 -1 } { 1 -1 } { 1 -2 } { 2 -1 } } $x $y] }

proc shapeHeight { shape } {
    set positions [$shape 0 0]
    set maxY 0
    foreach pos $positions {
        lassign $pos x y
        set maxY [expr max($maxY, abs($y) + 1)]
    }
    return $maxY
}

proc getShape { index } {
    set shapes [list horiz plus L line block]
    return [lindex $shapes [expr $index % [llength $shapes]]]
}

proc parseInput { infile } {
    global jetList jetIndex
    set jetIndex 0
    set jetList [string trim [read [open $infile r]]]
}

proc placeShape { shape x y } {
    global game

    #puts "placing $shape at $x $y"
    foreach pos [$shape $x $y] {
        lassign $pos px py
        set game($px,$py) #
    }
}

proc collide { shape x y } {
    global game
    # always collide with the floor
    if { $y < 0 } {
        return 1
    }

    foreach pos [$shape $x $y] {
        lassign $pos px py
        if { [info exists game($px,$py)] } {
            return 1
        }

        # left wall
        if { $px == -1 } {
            return 1
        }

        # right wall
        if { $px == 7 } {
            return 1
        }
    }
    
    return 0
}

proc printGame { highestY { shapePositions "" } } {
    global game
    set startY $highestY
    foreach pos $shapePositions {
        lassign $pos x y
        set startY [expr max($startY, $y)]
    }
    for { set y $startY } { $y >= 0 } { incr y -1 } {
        for { set x 0 } { $x < 7 } { incr x } {
            if { [lsearch $shapePositions [list $x $y]] >= 0 } {
                puts -nonewline @
            } elseif { [info exists game($x,$y)] } {
                puts -nonewline #
            } else {
                puts -nonewline "."
            }
        }
        puts ""
    }
    puts ""
}

proc encodeRow { height } {
    global game
    set word 0
    for { set x 0 } { $x < 7 } { incr x } {
        set word [expr ($word << 1)]
        if { ([info exists game($x,$height)]) } {
            set word [expr ($word | 1)]
        }
    }
    return $word
}

proc encode { height } {
    set encoded 0
    for { set y 0 } { $y < 32 } { incr y } {
        set encoded [expr (($encoded << 8) | [encodeRow [expr $height - $y]])]
    }
    return $encoded
}

proc step { shape highestY } {
    set x 2
    set y [expr ($highestY + [shapeHeight $shape] + 3)]
    #puts "starting at $x $y, highestY = $highestY, shape height [shapeHeight $shape]"
    set startingX $x
    set startingY $y

    #printGame $highestY [$shape $x $y]
    while { 1 } {
        set offset [jetOffset]
        set newX [expr ($x + $offset)]
        if { ![collide $shape $newX $y] } {
            set x $newX
        }

        set newY [expr ($y - 1)]
        if { [collide $shape $x $newY] } {
            placeShape $shape $x $y
            break
        } else {
            set y $newY
        }
    }
    global maxYDiff
    set maxYDiff [expr max($maxYDiff, [expr $startingY - $y])]

    return [list $x $y]
}

proc solve { numTimes } {
    global game
    array unset game
    
    global maxYDiff
    set maxYDiff 0

    set highestY -1
    set newDiffCount 0
    set oldDiffCount 0
	set firstSame -1

    set aft [encode $highestY]
    for { set i 0 } { $i < 10000 } { incr i } {
        set before $aft

        set shape [getShape $i]
        lassign [step $shape $highestY] x y
		set yDiff [expr max(0, $y - $highestY)]
        set highestY [expr max($highestY, $y)]
        set aft [encode $highestY]

		if { ($before == $aft) } {
			puts "didn't change?"
			exit
		}

        if { ([info exists cache($before)] && $cache($before) != $aft) } {
            puts "different result!"
            exit
        }

		#if { $before == $firstSame } {
		#	puts "same before: $shape"
		#	printGame $highestY
		#}

        if { $firstSame == -1 && [info exists cache($before)] } {
			set firstSame $before
			#break
		}
 
        if { [info exists shapes($before)] && $shapes($before) != $shape } {
            puts "was $shapes($before), now $shape"
            exit
        }

        if { $i > 64 } {
            set shapes($before) $shape
            set cache($before) $aft
            set yDiffs($before) $yDiff
        }
    }
	puts "cut off $i"

    set word $aft
	set startWord $aft
	set startI $i
	set yOffset 0
	set lastShape [getShape $i]
    for { set i $i } { $i < $numTimes } { incr i } {
		set shape [getShape $i]
        if { $shape != $shapes($word) } {
            puts "expected $shapes($word) got $shape"
            exit
        }

		incr highestY $yDiffs($word)
		incr yOffset $yDiffs($word)
        set word $cache($word)
        
        if { $i % 1000000 == 0 } {
            puts "i = $i"
        }

        puts "shape $shape"
		if { $word == $startWord } {
            incr i
            #set shape [getShape $i]
            #incr highestY $yDiffs($word)
            #incr yOffset $yDiffs($word)
			puts "shape $shape, last shape $lastShape"
			puts "repeated at $i, y diff $yOffset, cycles [expr $i - $startI]"
			break
		}
    }

    set repeatTime [expr $i - $startI]
	puts "repeats every $repeatTime"
	set repeatTimes [expr (($numTimes - $i) / $repeatTime)]
	incr highestY [expr $yOffset * $repeatTimes]
	incr i [expr ($repeatTimes * $repeatTime)]

    for { set i $i } { $i < $numTimes } { incr i } {
		incr highestY $yDiffs($word)
        set word $cache($word)
    }

    return [expr $highestY + 1]
}

parseInput $infile
#puts "Part 1: [solve 2022]"
puts "Part 2: [solve 1000000000000]"

