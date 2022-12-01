set lines [split [read [open input.txt r]] \n]
set max 0
foreach line $lines {
    if { $line == "" } {
        set max [expr max($max, $current)]
        lappend totals $current
        set current 0
    } else {
        incr current $line
    }
}
puts "Solution part 1"
puts $max

puts "Solution part 2"
lassign [lrange [lsort -integer -decreasing $totals] 0 2] a b c
puts [expr $a + $b + $c]
