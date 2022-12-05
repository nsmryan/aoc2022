
set input [split [read [open input.txt r]] "\n"]
#set input [split [read [open example.txt r]] "\n"]

set numStacks [expr ([string length [lindex $input 0]] + 1) / 4]
puts "num stacks $numStacks"
set stacks [list]
for { set stackIndex 1 } { $stackIndex <= $numStacks } { incr stackIndex } {
    dict set stacks $stackIndex [list]
}
puts $stacks

set index 0
while { [string first "]" [lindex $input $index]] >= 0 } {
    set line [lindex $input $index]
    for { set stackIndex 1 } { $stackIndex <= $numStacks } { incr stackIndex } {
        set chr [string index $line [expr ($stackIndex - 1) * 4 + 1]]
        if { $chr == " " } {
            continue
        }
        set items [dict get $stacks $stackIndex]
        lappend items $chr
        dict set stacks $stackIndex $items
    }
    incr index
}
puts "starting stacks"
puts $stacks

# skip unneeded input
incr index 
incr index 

while { $index < [llength $input] } {
    set line [lindex $input $index]
    if { [llength $line] == 0 } {
        break
    }
    set numMoveItems [lindex $line 1]
    set startIndex [lindex $line 3]
    set endIndex [lindex $line 5]
    #puts "startIndex $startIndex"

    set startStack [dict get $stacks $startIndex]
    set endStack [dict get $stacks $endIndex]

    set moveSection [lrange $startStack 0 [expr $numMoveItems - 1]]
    set endStack [concat $moveSection $endStack]
    set startStack [lrange $startStack $numMoveItems end]
    dict set stacks $startIndex $startStack
    dict set stacks $endIndex $endStack

    #puts $stacks
    #for { set i 0 } { $i < $numMoveItems } { incr i } {
    #    set startStack [dict get $stacks $startIndex]
    #    set endStack [dict get $stacks $endIndex]

    #    set endStack [linsert $endStack 0 [lindex $startStack 0]]
    #    set startStack [lrange $startStack 1 end]
    #    dict set stacks $startIndex $startStack
    #    dict set stacks $endIndex $endStack
    #}
    incr index
}

set result ""
dict for { stackIndex stack } $stacks {
    if { [llength $stack] > 0 } {
        set result $result[lindex $stack 0]
    }
}
puts $result
