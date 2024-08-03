$fn = 120;

use <gear.scad>

module spoked_with_drivers(d, w, rounding=1.45) {
    offset(rounding) offset(-2*rounding) offset(rounding)
    union() {
        spoked(d, w);
        for (a=[90:90:360]) rotate(a)
        translate([d/2,0])
        square([4*w, w], center=true);
    }
}

module pegs(d, h, n_peg, d_peg, h_peg) {
    linear_extrude(h) spoked_with_drivers(d, d_peg);
    for (i = [1 : n_peg]) {
        rotate(360 * i / n_peg) 
        translate([d/2 - d_peg/2, 0, 0])
        cylinder(d=d_peg, h=h_peg);
    }
}

module pegs_with_driver() {
    difference() {
        pegs(50, 2, 6, 3, 6);
        cylinder(d=3, h=10, center=true);
    }
}

module notch(d, h, d_notch, l_notch, rounding=1.5) {
    linear_extrude(h)
    offset(rounding) offset(-2*rounding) offset(rounding)
    difference() {
        union() {
            spoked(d, d_notch);
            intersection() {
                circle(d=d);
                offset(d_notch)
                translate([d/2, d_notch/2, 0])
                square([l_notch * 2, 2*d_notch], center=true);                
            }
        }
        translate([d/2, d_notch/2, 0])
        square([l_notch * 2, 2*d_notch], center=true);
    }
}

module notched_gear() {
    difference() {
        union() {
            linear_extrude(7)
            gear(10, 4, 1, 1.5, 25);
            notch(50, 2, 4, 10);
        }
        cylinder(d=3, h=20, center=true);
    }
}

module pegged_gear() {
    difference() {
        union() {
            linear_extrude(2)
            gear(60, 4, 1, 1.5, 25, 25);
            for (a=[90:90:360]) rotate(a) {
                translate([28,0]) cylinder(d=3, h=4);
            }
        }
        cylinder(d=3, h=20, center=true);
    }
}

module base() {
    translate([0,0,-1])
    linear_extrude(1) hull() {
        circle(d=30);
        translate([70,0]) circle(d=30);
    }
    for (x=[0, 140/PI]) translate([x,0,0])
        cylinder(d=2.5, h=10);
}

module demo() {
    rotate(30)
    translate([0,0,2])
    pegs_with_driver();
    
    translate([140/PI,0,7])
    rotate(180)
    mirror([0,0,1])
    color("green")
    notched_gear();

    color("blue") pegged_gear();

    base();
}

demo();

// base();

/*
translate([45, 50, 0])
pegs_with_driver();
*/

/*
translate([70,0,0])
notched_gear();
*/

// pegged_gear();
