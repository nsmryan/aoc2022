foreach { a b } [read [open input.txt r]] {
    set index [dict get [list X 0 Y 1 Z 2] $b]
    incr total1 [expr $index + 1 + 3 * (($index + 2 * [dict get [list A 0 B 1 C 2] $a] + 1) % 3)]
}
foreach { a b } [read [open input.txt r]] {
    set outcome [dict get [list X 0 Y 1 Z 2] $b]
    set oppIndex [dict get [list A 0 B 1 C 2] $a]
    incr total2 [expr [expr ($oppIndex + $outcome + 2) % 3] + 1 + 3 * $outcome]
}
puts $total1
puts $total2
