package require struct::set

set input [split [read [open input.txt r]] \n]
#set input [split [read [open example.txt r]] \n]

proc solve { input n } {
    foreach line $input {
        for { set index 0 } { $index < [string length $line] } { incr index } {
            lappend items [string index $line $index]
        }

        for { set index 0 } { $index < [llength $items] } { incr index } {
            if { [struct::set size [lrange $items $index [expr $index + $n - 1]]] == $n } {
                return [expr $index + $n]
            }
        }
    }
}

puts "Part 1: [solve $input 4]"
puts "Part 2: [solve $input 14]"
