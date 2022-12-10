set input [split [read [open input.txt r]] \n]
#set input [split [read [open example.txt r]] \n]


set x 1
set cycle 0
foreach line $input {
    if { $line == "" } {
        break
    }

    if { $line == "noop" } {

        set xpos [expr $cycle % 40]
        if { $xpos == 0 && $cycle > 0 } {
            puts ""
        }
        #puts "$cycle $x"

        if { abs($x - $xpos) < 2 } {
            puts -nonewline #
        } else {
            puts -nonewline .
        }
        incr cycle
    } else {
        set amount [lindex $line 1]

        set xpos [expr $cycle % 40]
        if { $xpos == 0 && $cycle > 0 } {
            puts ""
        }
        #puts "$cycle $x"

        if { abs($x - $xpos) < 2 } {
            puts -nonewline #
        } else {
            puts -nonewline .
        }
        incr cycle


        set xpos [expr $cycle % 40]
        if { $xpos == 0 && $cycle > 0 } {
            puts ""
        }
        #puts "$cycle $x"

        if { abs($x - $xpos) < 2 } {
            puts -nonewline #
        } else {
            puts -nonewline .
        }

        incr x $amount
        incr cycle
    }
}

