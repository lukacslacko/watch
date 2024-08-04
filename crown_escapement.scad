$fn = 120;

use <gear.scad>

module wheel_tooth(a) {
    rotate([90,0,0])
    linear_extrude(2, center=true)
    polygon([[0,0],[0,a],[-1, a], [-a/2,0]]);
}

module wheel() {
    n = 7;
    difference() {
        cylinder(d=40, h=7);
        cylinder(d=36, h=50, center=true);
    }
    translate([0,0,7]) intersection() {
        cylinder(d=40, h=30);
        for (i=[1:n]) rotate(360*i/n)
        translate([0,20-1,0])
        wheel_tooth(7);
    }
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
            for (a=[90:90:360]) {
                rotate(a) translate([43,0,0]) cylinder(d=12, h=5);
            }
        }
        cylinder(d1=5, d2=0, h=4);
        for (a=[90:90:360]) {
            #rotate(a) translate([43,0,1]) cylinder(d=9.5, h=5);
        }
    }
    translate([0,0,20])
    wing(8);
    rotate(-100)
    translate([0,0,55])
    wing(8);
}

module axle(e=0.08) {
    difference() {
        union() {
            intersection() {
                translate([0,0,11])
                cube([5-e, 5-e, 16], center=true);
                linear_extrude(16, scale=3/30) square(30, center=true);
            }
            cylinder(d=7, h=8);
            linear_extrude(6, convexity=10) gear(10);
            cylinder(d=d_outer(10), h=1);
        }
        cylinder(d=3, h=4);
    }
}

module weight_axle() {
    difference() {
        union() {
            cylinder(d=10, h=25);
            linear_extrude(6, convexity=10) gear(10);
        }
        cylinder(d=3, h=4);
        translate([0,0,12])
        rotate([90,0,0])
        cylinder(d=3, h=30, center=true);
    }
}

module last_gear() {
    wheel_and_pinion(50, 10);
}

module middle_gear() {
    wheel_and_pinion(60, 10);
}

module old_front_plate() {
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

/*
ESCAPE = [0,0,0];
LAST = [60,0,0]*2/PI;
MIDDLE = [60,70,0]*2/PI;
WEIGHT = [130,70,0]*2/PI;
*/

ESCAPE = [0,0,0];
LAST = [0,60,0]*2/PI;
MIDDLE = LAST + 70*2/PI*[cos(10),-sin(10),0];
WEIGHT = MIDDLE + 70*2/PI*[cos(45),-sin(45),0];

HOLES = [
    [-56, -41, 0],
    [-40, 40, 0],
    [94,40,0],
    [-30,0,0],
    [30,-15,0],
    [56, -41, 0],
    [94, -41, 0],
];

module back_plate() {
    difference() {
        union() {
            linear_extrude(2) difference() {
                translate([-60,-45]) square([158,90]);
                translate([0,-33])
                square([100,16], center=true);
                translate([-120,-10])
                square(60);
            }
            for (p=[ESCAPE, WEIGHT])
                translate(p) cylinder(d=2.4, h=5);
            for (p=[LAST, MIDDLE])
                translate(p) cylinder(d=2.4, h=11);
            translate([-60,-45])
            cube([112,4,8.4]);
            for (h=HOLES) translate(h + [0,0,4.4]) cube(8, center=true);
        }
        for (h=HOLES) translate(h) cylinder(d=4.5, h=30, center=true);
    }
}

module front_grid() {
    intersection() {
        union() {
            translate([-60,-45]) square([158,30]);
            translate([118-60,-45]) square([40,90]);
            for (e=[
                [HOLES[0],HOLES[3]],
                [HOLES[1],HOLES[3]],
                [HOLES[1],HOLES[2]],
                [HOLES[4],ESCAPE],
                [HOLES[3],ESCAPE],
                [ESCAPE,LAST],
                [HOLES[4],MIDDLE]
            ]) hull() {
                translate(e[0]) circle(d=15);
                translate(e[1]) circle(d=15);
            }
        }
        front_rectangle();
    }
}

module front_rectangle() {
    translate([-60,-45]) square([158,90]);
}

module front_plate() {
    linear_extrude(2) difference() {
        front_grid();
        translate([0,-33])
        square([100,16], center=true);
        translate([-120,-10])
        square(60);
        for (p=[LAST, MIDDLE])
            translate(p) circle(d=3);
        for (h=HOLES) translate(h) circle(d=4.5);
        translate(WEIGHT) circle(d=10.5);
        translate(ESCAPE) circle(d=7.5);
    }
    translate([-50,-45,0])
    cube([100,6,30]);
    translate([63,-45,0])
    cube([4,46,22]);
    translate([83,-45,0])
    cube([4,46,22]);
    difference() {
        intersection() {
            translate([63,-15,0])
            cube([24,16,22]);
            translate(WEIGHT)
            translate([0,0,19])
            for (a=[-45,45])
            rotate([0,a,0])
            translate([0,0,25])
            cube(50, center=true);
        }
        translate(WEIGHT)
        cylinder(d=10.5, h=19);
    }
    translate([0,-41,19])
    rotate([-90,0,0])
    cylinder(d1=10, d2=0, h=7);
    difference() {
        translate([-7.5,28,0])
        cube([15,4,30]);
        translate([0,28,19])
        rotate([90,0,0])
        cylinder(d=3.5, h=20, center=true);
    }
}

module train() {
    color("green")
    translate([0,0,-2])
    back_plate();
    translate(ESCAPE)
    axle();
    translate(LAST + [0,0,6])
    mirror([0,0,1])
    last_gear();
    translate(MIDDLE)
    middle_gear();
    translate(WEIGHT)
    weight_axle();
}

module demo2() {
    translate([0,0,-6.4])
    train();
    translate([0,0,2]) wheel();
    color("white")
    translate([0,-37.5,19])
    rotate([-90,0,0]) balance();
    color("red") front_plate();
}

translate([75,0,0]) wheel();
balance();

/*
axle();
translate([45,0,0]) last_gear();
translate([-20,45,0]) middle_gear();
*/