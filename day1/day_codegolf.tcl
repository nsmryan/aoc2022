foreach line [split [read [open input.txt r]] \n] {
    if { $line == "" } {
        lappend totals $current
        set current 0
    } else {
        incr current $line
    }
}
set totals [lsort -integer -decreasing $totals]
puts "Solution part 1: [lindex $totals 0]"
puts "Solution part 2 [::tcl::mathop::+ {*}[lrange $totals 0 2]]"
