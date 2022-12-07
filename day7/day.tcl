set input [split [read [open input.txt r]] \n]
#set input [split [read [open example.txt r]] \n]
set cur [list]

proc toDir { dirList } {
    set dir "/"
    foreach each $dirList {
        set dir $dir$each/
    }
    return $dir
}

foreach line $input {
    if { $line == "" } {
        break
    }
    if { $line == "$ cd /" } {
		set cur ""
    } elseif { $line == "$ ls" } {
    } elseif { $line == "$ cd .." } {
        set cur [lrange $cur 0 end-1]
    } elseif { [string first "$ cd"  $line] == 0 } {
        set newDir [lindex $line 2]
        lappend cur $newDir
    } else {
        set cwd [toDir $cur]
        if { ![info exists sizes($cwd)] } {
            set sizes($cwd) 0
            set subdirs($cwd) [list]
        }
        if { [lindex $line 0] == "dir" } {
            set subdir $cur
            lappend subdir [lindex $line 1]
            lappend subdirs($cwd) [toDir $subdir]
        } else {
            lassign $line size name
            #lappend files($cwd) $name
            incr sizes($cwd) $size
        }
    }
}

proc dirSize { dir } {
    global sizes subdirs
    set size $sizes($dir)
    foreach subdir $subdirs($dir) {
        incr size [dirSize $subdir]
    }
    return $size
}

foreach dir [array names sizes] {
    set totalSize [dirSize $dir]
    if { $totalSize <= 100000 } {
        incr total $totalSize
    }
}
puts "Part 1: $total"

set free [expr 70000000 - [dirSize /]]
puts "used [dirSize /]"
puts "free $free"
set total2 70000000
foreach dir [array names sizes] {
    set totalSize [dirSize $dir]
	if { ($free + $totalSize) >= 30000000 } {
		set total2 [expr min($totalSize, $total2)]
	}
}
puts "Part 2: $total2"