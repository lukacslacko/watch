$fn = 120;

use <gear.scad>

module sub() {
    difference() {
        union() {children([1:$children-1]);}
        children(0);
    }
}

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

/*
ESCAPE = [0,0,0];
LAST = [60,0,0]*2/PI;
MIDDLE = [60,70,0]*2/PI;
WEIGHT = [130,70,0]*2/PI;
*/

/*
ESCAPE = [0,0,0];
LAST = 60*2/PI*[cos(90), sin(90), 0];
MIDDLE = LAST + 70*2/PI*[cos(0),sin(0),0];
WEIGHT = MIDDLE + 85*2/PI*[cos(-30),sin(-30),0];
*/

MINUTE_CAM_RADIUS = 20;
MINUTE_CAM_DISTANCE = 90;
CAM_TOUCH_RADIUS = sqrt(MINUTE_CAM_RADIUS^2 + MINUTE_CAM_DISTANCE^2);
CAM_ANGLE = atan2(MINUTE_CAM_RADIUS, MINUTE_CAM_DISTANCE);
CAM_ESCAPE_DISTANCE = 60;

ESCAPE_TEETH = 14;
LAST_ESCAPE_TEETH = 4*14;
LAST_WEIGHT_TEETH = 14;
WEIGHT_TEETH = 5*14;

LAST_ESCAPE = (ESCAPE_TEETH + LAST_ESCAPE_TEETH)*2/PI;
WEIGHT_LAST = (LAST_WEIGHT_TEETH + WEIGHT_TEETH)*2/PI;

LAST_ANGLE = 45;
WEIGHT_ANGLE = -15;

ESCAPE = [0,0,0];
LAST = ESCAPE + LAST_ESCAPE * [cos(LAST_ANGLE), sin(LAST_ANGLE), 0];
WEIGHT = LAST + WEIGHT_LAST * [cos(WEIGHT_ANGLE), sin(WEIGHT_ANGLE), 0];

MINUTE_ESCAPE = WEIGHT + [CAM_ESCAPE_DISTANCE,0,0];
MINUTE_LEVER = WEIGHT - [MINUTE_CAM_DISTANCE,0,0];

BEHIND = [0,0,-8.4];

HOLES = [
    [-60, -40, 0],
    [-25, 25, 0],
    [105,65,0],
    [105, -40, 0],
    [30,-15,0]
];

function d2(p) = [p[0],p[1]];

PLATE = [d2(HOLES[0]), d2(HOLES[1]), d2(HOLES[2]), d2(HOLES[3])];

D_HOLE_BOTTOM_WEIGHT_AXLE = 25;


MINUTE_CAM_SHAPE = [
    for (phi=[2:2:360]) 
        MINUTE_CAM_RADIUS * (sin(3*phi) + 5)/5 *
        [cos(phi), sin(phi)]
];

module axle(e=0.08) {
    difference() {
        union() {
            intersection() {
                translate([0,0,11])
                cube([5-e, 5-e, 16], center=true);
                linear_extrude(16, scale=3/30) square(30, center=true);
            }
            cylinder(d=7, h=8);
            linear_extrude(6, convexity=10) gear(ESCAPE_TEETH);
            cylinder(d=d_outer(10), h=1);
        }
        cylinder(d=3, h=4);
    }
}

module weight_axle(
    d_axle=7, d_hole=14, d_driver=16, 
    d_hole_bottom=D_HOLE_BOTTOM_WEIGHT_AXLE) {
    difference() {
        union() {
            cylinder(d=d_hole, h=8);
            #translate([0,0,-8]) cylinder(d=d_hole_bottom, h=8);
            rotate(0) translate([0,0,-8.2]) 
            linear_extrude(5.8) polygon(MINUTE_CAM_SHAPE);
            translate([0,0,8])
            cylinder(d1=d_hole, d2=d_axle, h=2);
            translate([0,0,21])
            cylinder(d1=d_axle, d2=d_hole, h=2);
            translate([0,0,23])
            cylinder(d1=d_hole, d2=d_hole-.3, h=2);
            cylinder(d=d_axle,h=25);
            linear_extrude(6, convexity=10) square(d_driver, center=true);
        }
        translate([0,0,29])
        cube([1,d_driver,20],center=true);
        translate([0,0,-8])
        cylinder(d=3, h=8, center=true);
    }
}

module last_gear() {
    wheel_and_pinion(LAST_ESCAPE_TEETH, LAST_WEIGHT_TEETH);
}

module weight_wheel() {
    difference() {
        union() {
            linear_extrude(2) gear(WEIGHT_TEETH, d_inner=30);
            cylinder(d=30, h=6);
        }
        linear_extrude(30, center=true)
        square(16.2, center=true);
    }
}

module minute_escape() {
    difference() {
        union() {
            linear_extrude(3)
            union() {
                for (a=[72:72:360]) rotate(a) intersection() {
                    hull() {
                        translate([5,0])
                        circle(d=3);
                        translate([5,20])
                        circle(d=3);
                    }
                }
               circle(d=20); 
            }
            linear_extrude(6) gear(14);
            cylinder(d=12,h=8);
            translate([0,0,8])
            cube([8,8,16], center=true);
            cylinder(d=3,h=20);
        }
        cylinder(d=3, h=8, center=true);
    }
}

function pt(r, a) = r*[cos(a), sin(a)];

function arc(r, a1, a2, step) = [for (a=[a1:step:a2]) pt(r, a)];

module minute_lever() {
    linear_extrude(6)
    sub() {
        circle(d=4);
        circle(d=8);
        for (y=[1,0]) mirror([0,y])
        polygon(
            concat(
                [pt(CAM_TOUCH_RADIUS, CAM_ANGLE)],
                arc(CAM_TOUCH_RADIUS-2, CAM_ANGLE+1, 1.75*CAM_ANGLE, 1),
                arc(CAM_TOUCH_RADIUS+2, 1.75*CAM_ANGLE, CAM_ANGLE+1, -1)
            )
        );
        polygon(
            concat(
                arc(
                    MINUTE_CAM_RADIUS + MINUTE_CAM_DISTANCE + 8, 
                    -1.75*CAM_ANGLE, 1.75*CAM_ANGLE, 1
                ), 
                arc(
                    MINUTE_CAM_RADIUS + MINUTE_CAM_DISTANCE + 12, 
                    1.75*CAM_ANGLE, -1.75*CAM_ANGLE, -1
                )
            )
        );
        for (y=[1,0]) mirror([0,y])
        hull() {
            circle(d=4);
            translate(pt(120, 1.75*CAM_ANGLE)) circle(d=4);
        }
        r = CAM_ESCAPE_DISTANCE + MINUTE_CAM_DISTANCE;
        a = 15;
        polygon(concat(arc(r-2, -a, a, 1), arc(r+2, a, -a, -1)));
    }
}

module back_plate() {
    difference() {
        union() {
            linear_extrude(2) difference() {
                offset(5) polygon(PLATE);
                translate([0,-33])
                square([100,16], center=true);
            }
            for (p=[ESCAPE, WEIGHT])
                translate(p) cylinder(d=2.4, h=5);
            for (p=[LAST])
                translate(p) cylinder(d=2.4, h=11);
            translate(HOLES[0]-[0,5,0])
            cube([HOLES[3][0]-HOLES[0][0],4,8.4]);
            for (h=HOLES) {
                translate(h + [0,0,4.4]) 
                cylinder(d=10, h=8, center=true);
            }
        }
        for (h=HOLES) translate(h) cylinder(d=4.5, h=30, center=true);
        translate(WEIGHT) 
        cylinder(d=D_HOLE_BOTTOM_WEIGHT_AXLE + 0.4, h=30, center=true);
    }
}

module front_plate() {
    linear_extrude(2) difference() {
        offset(5) polygon(PLATE);
        translate([0,-33])
        square([100,16], center=true);
        translate([-120,-10])
        square(60);
        translate(LAST) circle(d=3);
        for (h=HOLES) translate(h) circle(d=4.5);
        translate(WEIGHT) circle(d=14.4);
        translate(ESCAPE) circle(d=7.5);
    }
    translate([-50,-45,0])
    cube([100,6,30]);
    translate([WEIGHT[0]-15,-45,0])
    cube([4,47+WEIGHT[1],22]);
    translate([WEIGHT[0]+11,-45,0])
    cube([4,47+WEIGHT[1],22]);
    difference() {
        intersection() {
            translate(WEIGHT)
            translate([-12,-16,0])
            cube([24,18,22]);
            translate(WEIGHT)
            translate([0,0,17])
            for (a=[-30,30])
            rotate([0,a,0])
            translate([0,0,24])
            cube(50, center=true);
        }
        translate(WEIGHT)
        cylinder(d=14.4, h=19);
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
    translate(WEIGHT)
    weight_wheel();
    color("pink")
    translate(WEIGHT)
    rotate(-0)
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
    color("white")
    translate(MINUTE_ESCAPE + [0,0,-14.6])
    rotate(0)
    minute_escape();
    color("cyan") translate(MINUTE_LEVER + [0,0,-14.6])
    rotate(-2.5)
    minute_lever();
}

demo2();
