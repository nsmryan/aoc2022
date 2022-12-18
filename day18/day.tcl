
proc free { x y z } {
    global map
    if { [info exists map($x,$y,$z)] } {
        return 0
    }
    return 1
}

proc solve { positions } {
    global map
    array unset map

    foreach pos $positions {
        lassign $pos x y z
        set map($x,$y,$z) .
    }

    foreach pos $positions {
        lassign $pos x y z
        incr count [free [expr $x + 1] $y $z]
        incr count [free [expr $x - 1] $y $z]
        incr count [free $x [expr $y + 1] $z]
        incr count [free $x [expr $y - 1] $z]
        incr count [free $x $y [expr $z + 1]]
        incr count [free $x $y [expr $z - 1]]
    }
    return $count
}

proc parse { infile } {
    set lines [read [open $infile r]]
    foreach line $lines {
        lappend xyz [split $line ,]
    }
    return $xyz
}

puts simple
set simple [solve { { 1 1 1 } { 2 1 1 } }]
if { $simple != 10 } {
    puts "simple example failed was $simple expected 10!"
    exit
}

puts example
set example [solve [parse example.txt]]
if { $example != 64 } {
    puts "example file failed was $example expected 64!"
    exit
}

puts actual
puts "Part 1: [solve [parse input.txt]]"
