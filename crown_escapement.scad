$fn = 120;

use <gear.scad>

module wheel_tooth(a) {
    rotate([90,0,0])
    linear_extrude(2, center=true)
    polygon([[0,0],[0,a],[-1, a], [-a/2,0]]);
}

module wheel() {
    n = 7;
    translate([0,0,-6])
    difference() {
        cylinder(d=40, h=6);
        cylinder(d=36, h=50, center=true);
    }
    intersection() {
        cylinder(d=40, h=30);
        for (i=[1:n]) rotate(360*i/n)
        translate([0,20-1,0])
        wheel_tooth(7);
    }
    translate([0,0,-12/2])
    difference() {
        linear_extrude(2) spoked(40, 3, 12);
        cube(5, center=true);
    }
}

module wing(a=10) {
    rotate([0,90,0])
    linear_extrude(1, center=true)
    polygon([[-a,0],[-a/2,a],[a/2,a],[a,0]]);
}

module balance() {
    difference() {
        union() {
            difference() {
                linear_extrude(5)
                spoked(100, 5, 20);
                translate([0,0,1])
                cylinder(d=90, h=10);
            }
            cylinder(d=20, h=5);
            cylinder(d=3, h=70);
        }
        cylinder(d1=5, d2=0, h=4);
    }
    translate([0,0,20])
    wing(10);
    rotate(-100)
    translate([0,0,55])
    wing(10);
}

module axle(e=0.08) {
    intersection() {
        translate([0,0,11])
        cube([5-e, 5-e, 22], center=true);
        linear_extrude(22, scale=3/30) square(30, center=true);
    }
    cylinder(d=7, h=15.4);
    intersection() {
        union() {
            cylinder(d1=0, d2=20, h=10);
            translate([0,0,10])
            cylinder(d=20, h=10);
        }
        linear_extrude(13.5, convexity=10) gear(9);
    }
}

module last_gear() {
    difference() {
        linear_extrude(6.5, convexity=10) gear(45, d_inner=20);
        cube([7.5,7.5,50], center=true);
    }
}

module last_axle() {
    translate([0,0,9])
    cube([7, 7, 7], center=true);
    cylinder(d=7, h=20);
}

module front_plate() {
    difference() {
        union() {
            cube([130,20,1.5], center=true);
            translate([0,18,0])
            cube([20,30,1.5], center=true);
            translate([-10,28,0])
            cube([20,4,30]);
            translate([-59,-40,-1.5/2])
            cube([4,50,30]);
            translate([55,-40,-1.5/2])
            cube([4,50,30]);
            translate([-60,-43,-1.5/2])
            cube([120,4,30]);
            translate([0,-40,19])
            rotate([-90,0,0])
            cylinder(d1=10, d2=0, h=7);
        }
        cylinder(d=7.5, h=10, center=true);
        translate([54*2/PI,0,0]) cylinder(d=7.5, h=10, center=true);
        translate([0,28,19])
        rotate([90,0,0])
        cylinder(d=3.5, h=20, center=true);
    }
}


module demo() {
    translate([0,12,75/2])
    rotate([90,0,0]) {
        color("green")
        rotate(-5) wheel();
        translate([0,0,-22])
        axle();
        color("blue")
        translate([54*2/PI,0,6.5-22]) last_gear();
        color("pink")
        translate([54*2/PI,0,-22]) last_axle();
        translate([0,0,-7])
        color("grey") front_plate();
    }
    color("red")
    rotate(100-30)
    balance();
}

demo();