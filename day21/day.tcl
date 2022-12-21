package require struct::tree

set infile input.txt
#set infile example.txt


proc parse { infile } {
    foreach line [split [string trim [read [open $infile r]]] \n] {
        lassign [split $line :] name expression
        if { [llength $expression] == 1 } {
            dict set ready $name $expression
        } else {
            dict set waiting $name $expression
        }
    }
    return [list $waiting $ready]
}

proc solve1 { state } {
    lassign $state waiting ready
    while { [dict size $waiting] > 0 } {
        foreach name [dict keys $waiting] {
            lassign [dict get $waiting $name] left op right
            if { [dict exists $ready $left] && [dict exists $ready $right] } {
                set leftValue [dict get $ready $left]
                set rightValue [dict get $ready $right]
                dict set ready $name [expr $leftValue $op $rightValue]
                set waiting [dict remove $waiting $name]
            }
        }
    }
    return [dict get $ready root]
}

proc fillTree { tree parent node waiting ready } {
    $tree insert $parent end $node 
    if { [dict exists $waiting $node] } {
        lassign [dict get $waiting $node] left op right

        $tree set $node operator $op
        $tree set $node type operator

        fillTree $tree $node $left $waiting $ready
        fillTree $tree $node $right $waiting $ready
    } elseif { $node == "humn" } {
        $tree set $node type variable
    } else {
        $tree set $node value [dict get $ready $node]
        $tree set $node type constant
    }
}

proc isConstant { tree node } {
    return [string equal [$tree get $node type] "constant"]
}

proc isOperator { tree node } {
    return [string equal [$tree get $node type] "operator"]
}

proc isSimple { tree node } {
    if  { [isOperator $tree $node] } {
        foreach child [$tree children $node] {
            if { ![isConstant $tree $child] } {
                return 0
            }
        }
        return 1
    } else {
        return 0
    }
}

proc getValue { tree node } {
    return [$tree get $node value]
}

proc printTree { tree node } {
    printNode $tree $node
    puts ""
}

proc printNode { tree node } {
    if { [isConstant $tree $node] } {
        puts -nonewline " [getValue $tree $node]"
    } elseif { [isOperator $tree $node] } {
        puts -nonewline " ([$tree get $node operator] "
        foreach child [$tree children $node] {
            printNode $tree $child
        }
        puts -nonewline ")"
    } else {
        puts -nonewline " x"
    }
}

proc simplify { tree node } {
    if { [isSimple $tree $node] } {
        lassign [$tree children $node] left right
        set op [$tree get $node operator]
        set value [expr [getValue $tree $left] $op [getValue $tree $right]]
        #puts "$node: [getValue $tree $left] $op [getValue $tree $right] = $value"

        $tree delete $left
        $tree delete $right

        $tree set $node type constant 
        $tree set $node value $value 
        return 1
    } else {
        set simpler 0
        foreach child [$tree children $node] {
            set simpler [expr $simpler || [simplify $tree $child]]
        }
        return $simpler
    }
}

proc canonicalize { tree node } {
    if { [isOperator $tree $node] } {
        lassign [$tree children $node] left right
        set op [$tree get $node operator]
        if { $op == "+" || $op == "*" } {
            if { [isConstant $tree $left] && ![isConstant $tree $right] } {
                $tree move $node end $left
            }
        }

        canonicalize $tree $left
        canonicalize $tree $right
    }
}

proc equate { tree rhs } {
    while { [$tree get [$tree children root] type] != "variable" } {
        set node [$tree children root]
        set op [$tree get $node operator]
        lassign [$tree children $node] left right
        set oldRhs $rhs
        switch $op {
            + {
                set rhs [expr $rhs - [getValue $tree $right]]
                $tree delete $right
                $tree cut $node
            }

            - { 
                if { [isConstant $tree $right] } {
                    set rhs [expr $rhs + [getValue $tree $right]]
                    $tree delete $right
                } else {
                    set rhs [expr -1 * ($rhs - [getValue $tree $left])]
                    $tree delete $left
                }
                $tree cut $node
            }

            * {
                set rhs [expr $rhs / [getValue $tree $right]]
                $tree delete $right
                $tree cut $node
            }

            / {
                if { [isConstant $tree $right] } {
                    set rhs [expr $rhs * [getValue $tree $right]]
                    $tree delete $right
                } else {
                    set rhs [expr [getValue $tree $left) / $rhs]
                    $tree delete $left
                }
                $tree cut $node
            }
        }
    }

    return $rhs
}

proc solve2 { state } {
    lassign $state waiting ready
    lassign [dict get $waiting root] rootLeft rootOp rootRight

    set waiting [dict remove $waiting root]
    #set ready [dict remove $ready humn]

    struct::tree left
    fillTree left root $rootLeft $waiting $ready
    #printTree left $rootLeft
    while { [simplify left $rootLeft] } {}
    canonicalize left $rootLeft
    #printTree left $rootLeft

    struct::tree right
    fillTree right root $rootRight $waiting $ready
    while { [simplify right $rootRight] } {}

    set rhs [right get $rootRight value]
    return [equate left $rhs]
}

set state [parse $infile]
puts "Part 1: [solve1 $state]"

puts "Part 2: [solve2 $state]"
