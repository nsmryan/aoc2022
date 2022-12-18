package require struct::graph
package require struct::graph::op

set infile input.txt
#set infile example.txt

struct::graph map

proc lremove {var value} {
    set idx [lsearch -exact $var $value]
    return [lreplace $var $idx $idx]
}

proc parseLine { line } {
    regexp {Valve ([A-Z]+) has flow rate=(\d+); tunnels? leads? to valves? (.*$)} $line matched node rate valves
    return [list $node $rate [string map {, ""} $valves]]
}

proc readInput { infile } {
    foreach line [split [read [open $infile r]] \n] {
        if { $line == "" } continue
        lassign [parseLine $line] node rate valves

        if { ![map node exists $node] } {
            map node insert $node
        }

        foreach valve $valves {
            if { ![map node exists $valve] } {
                map node insert $valve
            }
            set arc [map arc insert $node $valve]
            map arc setweight $arc 1
        }
        map node set $node rate $rate
    }
}

proc compareRates { a b } {
    set arate [map node get $a rate] 
    set brate [map node get $b rate] 
    if { $arate > $brate } {
        return 1
    } elseif { $arate < $brate } {
        return -1
    } else {
        return 0
    }
}

proc solve { infile } {
    readInput $infile
    set closedAll [lrange [lsort [map nodes]] 1 end]
    puts $closedAll
    foreach node $closedAll {
        if { [map node get $node rate] > 0 } {
            lappend closed $node
        }
    }
    puts $closed
    set closed [lsort -command compareRates $closed]
    puts $closed

    global globalMaxFlow
    set globalMaxFlow 0

    set paths [struct::graph::op::FloydWarshall map]
    set minute 1
    set total 0
    set flow 0
    set node AA

    set flow [step $node $node $minute $minute $closed $paths $flow]
    return $flow
}

proc step { node enode minute eminute closed paths flow } {
    global completedCount globalMaxFlow 

    set maxFlow $flow

    set remainingRate 0
    foreach nextNode $closed {
        incr remainingRate [map node get $nextNode rate]
    }
    set remainingFlow [expr $flow + ($remainingRate * (27 - min($minute, $eminute)))]
    if { $remainingFlow < $globalMaxFlow } {
        # exit early
        incr completedCount
        if { $completedCount % 10000 == 0 } {
            puts $completedCount
        }
        return $flow
    }

    foreach nextNode $closed {
        set dist [dict get $paths [list $node $nextNode]]
        set newMinute [expr $minute + $dist]

        incr newMinute
        set incrFlow [expr [map node get $nextNode rate] * (27 - $newMinute)]
        set newFlow [expr $flow + $incrFlow]
        set newClosed [lremove $closed $nextNode]

        if { $newMinute < 27 } {
            lassign [step $nextNode $enode $newMinute $eminute $newClosed $paths $newFlow] resultFlow newPath
            if { $resultFlow > $maxFlow } {
                set maxFlow $resultFlow
                #set maxPath $newPath
                #lappend maxPath [list e $nextNode $minute $newMinute $incrFlow $dist]
            }
        }

        if { 1 } {
            set edist [dict get $paths [list $enode $nextNode]]
            set enewMinute [expr $eminute + $edist]

            incr enewMinute
            set incrFlow [expr [map node get $nextNode rate] * (27 - $enewMinute)]
            set newFlow [expr $flow + $incrFlow]
            set newClosed [lremove $closed $nextNode]

            if { $enewMinute < 27 } {
                lassign [step $node $nextNode $minute $enewMinute $newClosed $paths $newFlow] resultFlow newPath
                if { $resultFlow > $maxFlow } {
                    set maxFlow $resultFlow
                    #set maxPath $newPath
                    #lappend maxPath [list m $nextNode $eminute $enewMinute $incrFlow $edist]
                }
            }
        }
    }

    if { $maxFlow > $globalMaxFlow } {
        set globalMaxFlow $maxFlow
    }

    incr completedCount
    if { $completedCount % 10000 == 0 } {
        puts $completedCount
    }

    return $maxFlow
}

puts "Part 1: [solve $infile]"
