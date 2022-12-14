
set input [split [read [open input.txt r]] \n]
#set input [split [read [open example.txt r]] \n]

set id 0
set mod 1
foreach { idLine start opLine test trueLine falseLine blank } $input {
    set items($id) [lrange [string map [list , ""] $start] 2 end]

    set opExpr [lrange $opLine 3 end]
    foreach part $opExpr {
        if { $part == "old" } {
            lappend op($id) \$$part
        } else {
            lappend op($id) $part
        }
    }

    set div($id) [lindex $test end]
    set mod [expr $mod * $div($id)]

    set true($id) [lindex $trueLine end]
    set false($id) [lindex $falseLine end]

    incr id
}

proc divisible { n d } {
    return [expr $n == int(round((floor($n / $d) * $d)))]
}

proc printout { } {
    global items
    foreach id [array names items] {
        puts "$id $items($id)"
    }
}

proc round { } {
    global items op div true false counts mod

    set numIds [llength [array names items]]
    for { set id 0 } { $id < $numIds } { incr id } {
        incr counts($id) [llength $items($id)]
        foreach item $items($id) {
            set old $item
            set new [eval "expr $op($id)"]
            #set new [expr $new / 3]
            set new [expr $new % $mod]
            if { [divisible $new $div($id)] } {
                lappend items($true($id)) $new
            } else {
                lappend items($false($id)) $new
            }
        }
        set items($id) [list]
    }
}

set numRounds 10000
for { set i 0 } { $i < $numRounds } { incr i } {
    #puts "round $i"
    round
}
#puts "final"
#printout

set finalCounts [lmap x [array names counts] { expr $counts($x) } ]
#puts "final counts: [lsort -decreasing -integer $finalCounts]"
lassign [lrange [lsort -decreasing -integer $finalCounts] 0 1] first second
puts [expr $first * $second]
