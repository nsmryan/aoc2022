proc rangeWithin { l0 h0 l1 h1 } {
    return [expr $l0 >= $l1 && $h0 <= $h1]
}
proc rangeContained { l0 h0 l1 h1 } {
    return [expr [rangeWithin $l0 $h0 $l1 $h1] || [rangeWithin $l1 $h1 $l0 $h0]]
}

proc overlap { l0 h0 l1 h1 } {
    return [expr ($l0 >= $l1 && $l0 <= $h1) || ($h0 >= $l1 && $h0 <= $h1)]
}

proc anyOverlap {  l0 h0 l1 h1 } {
    return [expr [overlap $l0 $h0 $l1 $h1] || [overlap $l1 $h1 $l0 $h0]]
}

set fileName input.txt
#set fileName example.txt
foreach line [read [open $fileName r]] {
    lassign [split $line ,] first second
    lassign [split $first -] l0 h0
    lassign [split $second -] l1 h1

    if { [rangeContained $l0 $h0 $l1 $h1] } {
        incr total1
    }

    if { [anyOverlap $l0 $h0 $l1 $h1] } {
        incr total2
    }
}
puts "Part 1: $total1"
puts "Part 2: $total2"
