package require struct::set

set input [split [read [open input.txt r]] \n]
#set input [split [read [open example.txt r]] \n]
#set input [split [read [open example2.txt r]] \n]

set offsets [list R [list 1 0] L [list -1 0] U [list 0 -1] D [list 0 1]]

set total1 0
set total2 0

set hx 0
set hy 0
set tx 0
set ty 0

proc distance { x0 y0 x1 y1 } {
    return [expr max(abs($x0 - $x1), abs($y0 - $y1))]
}

proc sign { value } {
    if { $value == 0 } {
        return 0
    } elseif { $value > 0 } {
        return 1
    } else {
        return -1
    }
}

struct::set include visited ($tx,$ty)

foreach line $input {
    if { $line == "" } continue
    lassign $line dir amount

    lassign [dict get $offsets $dir] xOffset yOffset

    for { set index 0 } { $index < $amount } { incr index } {
        incr hx $xOffset
        incr hy $yOffset

        if { [distance $hx $hy $tx $ty] > 1 } {
            set txOffset [sign [expr $hx - $tx]]
            set tyOffset [sign [expr $hy - $ty]]

            incr tx $txOffset
            incr ty $tyOffset

            struct::set include visited ($tx,$ty)
        }
    }

}

set total1 [struct::set size $visited]
puts "Part 1: $total1"

puts "Part 2: $total2"
