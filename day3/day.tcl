set input [read [open input.txt r]]
#set input [list vJrwpWtwJgWrhcsFMMfFFhFp jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL PmmdzqPrVvPwwTWBwg wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn ttgJtRGJQctTZtZT CrZsJsPPZsGzwwsLwLmpwMDw]

proc findSame { first second } {
    set numItems [string length $first]
    for { set i 0 } { $i < $numItems } { incr i } {
        for { set j 0 } { $j < $numItems } { incr j } {
            if { [string index $first $i] == [string index $second $j] } {
                return [string index $first $i]
            }
        }
    }
}

proc priority { chr } {
    binary scan a c a
    binary scan z c z
    binary scan A c A
    binary scan Z c Z

    binary scan $chr c ord
    if { $ord >= $A && $ord <= $Z } {
        return [expr 27 + $ord - $A]
    } else {
        return [expr 1 + $ord - $a]
    }
}

foreach line $input {
    set numItems [expr [string length $line] / 2]
    set first [string range $line 0 [expr $numItems - 1]]
    set second [string range $line $numItems end]
    set same [findSame $first $second]
    incr total [priority $same]
}
puts "Part 1: $total"

# struct::set would be faster, but this is easy enough.
proc findSame { first second third } {
    for { set i 0 } { $i < [string length $first] } { incr i } {
        for { set j 0 } { $j < [string length $second] } { incr j } {
            for { set k 0 } { $k < [string length $third] } { incr k } {
                if { [string index $first $i] == [string index $second $j] && [string index $second $j] == [string index $third $k] } {
                    return [string index $first $i]
                }
            }
        }
    }
	puts "hmmm"
}

foreach { one two three } $input {
    incr total2 [priority [findSame $one $two $three]]
}
puts "Part 2: $total2"