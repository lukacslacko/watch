$fn = 120;

module spoke_holes(d, w, d_inner=0) {
    for (a = [90:90:360]) rotate(a) {
        offset(w) offset(-w)
        difference() {
            intersection() {
                translate([w/2, w/2]) square(d);
                circle(d=d-2*w);
            }
            circle(d=d_inner);
        }
    }
}

module spoked(d, w, d_inner=0) {
    difference() {
        circle(d=d);
        spoke_holes(d, w, d_inner);
    }
}

module wheel_tooth(a, h) {
    rotate([90,0,0])
    linear_extrude(100)
    polygon([[-a,h],[0,0],[a,0],[a,h]]);
}

module wheel() {
    n = 9;
    difference() {
        cylinder(d=40, h=15, center=true);
        cylinder(d=35, h=20, center=true);
        for (i=[1:n]) rotate(360*i/n)
        wheel_tooth(7,8);
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
    wing();
    rotate(-100)
    translate([0,0,55])
    wing();
}

/*
translate([0,12,40])
rotate([90,0,0]) rotate(-25) wheel();
*/
rotate(0)
balance();