set input [read [open input.txt r]]
#set input [list A Y B X C Z]

set values [list X 1 Y 2 Z 3]
set opponentIndices [list A 0 B 1 C 2]
set myIndices [list X 0 Y 1 Z 2]

proc determineOutcome { opp mine } {
    global opponentIndices myIndices 
    set outcomes [list draw win lose]

    set oppIndex [dict get $opponentIndices $opp]
    set myIndex [dict get $myIndices $mine]
    set index [expr ($myIndex - $oppIndex) % 3]

    return [lindex $outcomes $index]
}

# Part 1
set scores [list draw 3 lose 0 win 6]
foreach { theirs mine} $input {
    set outcome [determineOutcome $theirs $mine]
    set outcomeScore [dict get $scores $outcome]
    set moveScore [dict get $values $mine]
    set score [expr $outcomeScore + $moveScore]
    incr total $score
}

puts "part 1: $total"

# Part 2
set scores [list X 0 Y 3 Z 6]
proc determineOutcome { opp mine } {
    set part2 [list AX Z AY X AZ Y BX X BY Y BZ Z CX Y CY Z CZ X]
    return [dict get $part2 $opp$mine]
}
set outcomeMap [list X lose Y draw Z win]
set total 0
foreach { theirs desiredOutcome } $input {
    set move [determineOutcome $theirs $desiredOutcome]
    set outcomeScore [dict get $scores $desiredOutcome]
    set moveScore [dict get $values $move]
    set score [expr $outcomeScore + $moveScore]
    incr total $score
}
puts "part 2: $total"
