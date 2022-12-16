set infile input.txt
set infile example.txt

proc lremove {var value} {
    set idx [lsearch -exact $var $value]
    return [lreplace $var $idx $idx]
}

proc parseLine { line } {
    regexp {Valve ([A-Z]+) has flow rate=(\d+); tunnels? leads? to valves? (.*$)} $line matched node rate valves
    return [list $node $rate [string map {, ""} $valves]]
}

proc readInput { infile } {
    global arcs rates
    foreach line [split [read [open $infile r]] \n] {
        if { $line == "" } continue
        lassign [parseLine $line] node rate valves
        set arcs($node) $valves
        set rates($node) $rate
    }
}

proc solve { infile } {
    global arcs rates
    readInput $infile
    set closed [lrange [lsort [array names arcs]] 1 end]

    set minute 0
    set total 0
    set flow 0
    set node AA
    lassign [step $node $minute $closed 0] flow
    return $flow
}

proc step { node minute closed flow } {
    global arcs rates
    if { [llength $closed] == 0 } {
        puts "Flow $flow"
        return $flow
    }

    if { $minute > 30 } {
        puts "Flow $flow"
        return $flow
    }
    #puts "$node at $minute with flow $flow, closed = $closed"

    set maxFlow $flow

    if { [lsearch $closed $node] >= 0 } {
        set newClosed [lremove $closed $node]
        set newMinute [expr $minute + 1]

        if { $newMinute > 30 } {
            puts "Flow $maxFlow"
            return $maxFlow
        }

        set newFlow [expr $flow + (30 - $minute) * $rates($node)]
        foreach adj $arcs($node) {
            set maxFlow [expr max($maxFlow, [step $adj $newMinute $newClosed $newFlow])]
        }
    }

    incr minute
    if { $minute > 30 } {
        puts "Flow $maxFlow"
        return $maxFlow
    }

    foreach adj $arcs($node) {
        set maxFlow [expr max($maxFlow, [step $adj $minute $closed $flow])]
    }

    return $maxFlow
}

puts "Part 1: [solve $infile]"

