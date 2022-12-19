set infile input.txt
set infile example.txt

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

proc step { shape highestY } {
    global shapeResults

    set x 2
    set y [expr $highestY + [shapeHeight $shape] + 3]
    #puts "starting at $x $y, highestY = $highestY, shape height [shapeHeight $shape]"
    set startingX $x
    set startingY $y

    #printGame $highestY [$shape $x $y]
    while { 1 } {
        set offset [jetOffset]
        set newX [expr $x + $offset]
        if { ![collide $shape $newX $y] } {
            set x $newX
        }

        set newY [expr $y - 1]
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
    for { set i 0 } { $i < $numTimes } { incr i } {
        set shape [getShape $i]
        lassign [step $shape $highestY] x y
        set highestY [expr max($highestY, $y)]
        if { $i % 10000 == 0 } {
            puts "$i max Y diff $maxYDiff"
        }
    }
    #printGame $highestY
    return [expr $highestY + 1]
}

parseInput $infile
puts "Part 1: [solve 2022]"
#puts "Part 2: [solve 1000000000000]"

