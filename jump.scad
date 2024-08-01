$fn = 120;

module spoked(d, w) {
    difference() {
        circle(d=d);
        for (a = [90:90:360]) rotate(a) {
            offset(w) offset(-w)
            intersection() {
                translate([w/2, w/2]) square(d);
                circle(d=d-2*w);
            }
        }
    }
}

module pegs(d, h, n_peg, d_peg, h_peg) {
    linear_extrude(h) spoked(d, d_peg);
    for (i = [1 : n_peg]) {
        rotate(360 * i / n_peg) 
        translate([d/2 - d_peg/2, 0, 0])
        cylinder(d=d_peg, h=h_peg);
    }
}

module driven_pegs(d, h, n_peg, d_peg, h_peg, rounding=1.45) {
    linear_extrude(h) {
        offset(rounding) offset(-2*rounding) offset(rounding)
        for (a=[45:90:360]) rotate(a)
        union() {
            difference() {
                circle(d=d);
                circle(d=d-2*d_peg);
            }
            intersection() {
                circle(d=d);
                translate([d/2-d_peg,0])
                square([3*d_peg, d_peg], center=true);
            }
        }
    }
    translate([0,0,h]) pegs(d, h, n_peg, d_peg, h_peg);
}

module driving_spring(d, h, d_peg) {
    linear_extrude(h) {
        difference() {
            union() {
                circle(d=3*d_peg);
                for (a=[0, 90]) rotate(a) {
                    square([d-3*d_peg, 1], center=true);
                }
            }
            square(1.5*d_peg, center=true);
        }
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
                translate([d/2, 0, 0])
                square([l_notch * 2, d_notch], center=true);                
            }
        }
        translate([d/2, 0, 0])
        square([l_notch * 2, d_notch], center=true);
    }
}

rotate(30)
driven_pegs(50, 2, 6, 3, 6);
translate([44.5,0,5])
rotate(180-0)
color("green")
notch(50, 2, 4, 10);
color("red") driving_spring(50, 1.8, 3);