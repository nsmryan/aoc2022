package require struct::set

proc inAir { x y z } {
    global air surface
    set pos [list $x $y $z]
    if { ![struct::set contains $surface $pos] } {
        struct::set include air $pos
    }
}

proc free { x y z } {
    global air
    set pos [list $x $y $z]
    if { [struct::set contains $air $pos] } {
        return 1
    }
    return 0
}

proc fill { x y z } {
    global surface filled floodfill

    set max 21
    if { $x < -1 || $y < -1 || $z < -1 || $x >= $max || $y >= $max || $z >= $max } {
        return
    }

    set pos [list $x $y $z]
    if { ![struct::set contains $surface $pos] && ![struct::set contains $filled $pos] } {
        struct::set include floodfill $pos
    }
}

proc offsets { x y z } {
    lappend result [list [expr $x + 1] $y $z]
    lappend result [list [expr $x - 1] $y $z]
    lappend result [list $x [expr $y + 1] $z]
    lappend result [list $x [expr $y - 1] $z]
    lappend result [list $x $y [expr $z + 1]]
    lappend result [list $x $y [expr $z - 1]]
}

proc printout { } {
    global air filled surface
    for { set z -5 } { $z < 21 } { incr z } {
        for { set y -5 } { $y < 21 } { incr y } {
            for { set x -5 } { $x < 21 } { incr x } {
                set pos [list $x $y $z]
                if { [struct::set contains $surface $pos] } {
                    puts -nonewline #
                } elseif { [struct::set contains $air $pos] } {
                    puts -nonewline &
                } elseif { [struct::set contains $filled $pos] } {
                    puts -nonewline .
                } else {
                    puts -nonewline i
                }
            }
            puts ""
        }
        puts "+________________________________"
    }
    puts ""
}

proc solve { positions } {
    global air filled floodfill surface
    set air [list]
    set filled [list]
    set surface [list]
    set floodfill [list [list 0 0 0]]

    foreach pos $positions {
        struct::set include surface $pos
    }

    if { [llength $positions] != [struct::set size $surface] } {
        puts "[llength $positions] != [struct::set size $surface]"
        puts hmm
        exit
    }

    foreach pos $positions {
        lassign $pos x y z
        inAir [expr $x + 1] $y $z
        inAir [expr $x - 1] $y $z
        inAir $x [expr $y + 1] $z
        inAir $x [expr $y - 1] $z
        inAir $x $y [expr $z + 1]
        inAir $x $y [expr $z - 1]
    }

    while { [llength $floodfill] > 0 } {
        #puts "[llength $filled] [llength $floodfill]"
        set lastfill $floodfill
        set floodfill [list]
        foreach pos $lastfill {
            lassign $pos x y z
            fill [expr $x + 1] $y $z
            fill [expr $x - 1] $y $z
            fill $x [expr $y + 1] $z
            fill $x [expr $y - 1] $z
            fill $x $y [expr $z + 1]
            fill $x $y [expr $z - 1]
        }
        set filled [struct::set union $filled $floodfill]
    }

    set air [struct::set intersect $air $filled]

    puts "num positions [llength $positions]"
    puts "num air [llength $air]"
    puts "num filled [llength $filled]"
    puts "num surface [llength $surface]"
    set count 0
    foreach pos $positions {
        lassign $pos x y z
        incr count [free [expr $x + 1] $y $z]
        incr count [free [expr $x - 1] $y $z]
        incr count [free $x [expr $y + 1] $z]
        incr count [free $x [expr $y - 1] $z]
        incr count [free $x $y [expr $z + 1]]
        incr count [free $x $y [expr $z - 1]]
    }
    #printout
    return $count
}

proc parse { infile } {
    set lines [string trim [read [open $infile r]]]
    foreach line $lines {
        lappend xyz [split $line ,]
    }
    return $xyz
}

#puts example
#set example [solve [parse example.txt]]
#if { $example != 58 } {
#    puts "example file failed was $example expected 58!"
#    exit
#}

puts actual
puts "Part 2: [solve [parse input.txt]]"
