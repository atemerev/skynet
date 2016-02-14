#!/usr/bin/env tclsh
package require Tcl 8.6
namespace path ::tcl::mathop

coroutine gensym apply {{} {
    set i 0
    while 1 {
        yield coro$i
        incr i
    }
}}

proc skynet {num size div} {
    yield
    if {$size == 1} {
        yield $num
    } else {
        set children {}
        set childSize [/ $size $div]
        for {set i 0} {$i < $div} {incr i} {
            set childNum [+ $num [* $i $childSize]]
            set id [gensym]
            coroutine $id skynet $childNum $childSize $div
            lappend children $id
        }
        set sum 0
        foreach child $children {
            incr sum [$child]
        }
        yield $sum
    }
}

proc main {} {
    coroutine mainCoro skynet 0 1000000 10
    set sum [mainCoro]
    if {$sum != 499999500000} {
        error "sum is $sum"
    }
}

main
