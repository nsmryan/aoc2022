set input [split [read [open input.txt r]] \n]
#set input [split [read [open example.txt r]] \n]


set x 1
set cycle 0
set score 0
set mod 20
foreach line $input {
    if { $line == "" } {
        puts done
        break
    }

    if { $line == "noop" } {
        incr cycle
        if { ($cycle % $mod) == 0 } {
            puts "$x $cycle [expr $cycle * $x]"
            incr score [expr $cycle * $x]
            set mod [expr $mod + 40]
        }
    } else {
        set amount [lindex $line 1]
        incr cycle

        if { ($cycle % $mod) == 0 } {
            puts "$x $cycle [expr $cycle * $x]"
            incr score [expr $cycle * $x]
            set mod [expr $mod + 40]
        }

        incr cycle

        if { ($cycle % $mod) == 0 } {
            puts "$x $cycle [expr $cycle * $x]"
            incr score [expr $cycle * $x]
            set mod [expr $mod + 40]
        }
        incr x $amount
    }
}

puts $score
