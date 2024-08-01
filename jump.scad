$fn = 120;

function involute_point(
    pitch_diameter, pressure_angle, angle
) = let(
    pitch_radius = pitch_diameter/2,
    base_radius = pitch_radius * cos(pressure_angle),
    circle_angle = angle + pressure_angle,
    circle_point = base_radius * [-sin(circle_angle), cos(circle_angle)],
    zero_rope_length = pitch_radius * sin(pressure_angle),
    rope_length = zero_rope_length + base_radius * angle * PI / 180,
    rope_direction = [cos(circle_angle), sin(circle_angle)]
) circle_point + rope_length * rope_direction;

module involute_arc(
    pitch_diameter, pressure_angle, angle_range
) {
   polygon(concat(
        [[0,0]], 
        [for (angle=angle_range) 
            involute_point(pitch_diameter, pressure_angle, angle)]
    ));
}    

module one_tooth(pitch_diameter, pressure_angle, tooth_width_angle) {
    intersection() {
        rotate(-tooth_width_angle/2) involute_arc(
            pitch_diameter, pressure_angle, 
            [-pressure_angle:1:2*pressure_angle]);
        mirror([1,0])
        rotate(-tooth_width_angle/2) involute_arc(
            pitch_diameter, pressure_angle, 
            [-pressure_angle:1:2*pressure_angle]);
    }
}

module gear(n_tooth, pitch, addendum, dedendum, pressure_angle) {
    pitch_diameter = pitch * n_tooth / PI;
    difference() {
        union() {
            intersection() {
                for (i=[1:n_tooth]) {
                    rotate(360/n_tooth*i) 
                    one_tooth(pitch_diameter, pressure_angle, 180/n_tooth);
                }
                circle(d=pitch_diameter + 2*addendum);
            }
            circle(d=pitch_diameter - 2*dedendum);
        }
        spoke_holes(pitch_diameter - 2*dedendum, pitch);
    }
}

module spoke_holes(d, w) {
    for (a = [90:90:360]) rotate(a) {
        offset(w) offset(-w)
        intersection() {
            translate([w/2, w/2]) square(d);
            circle(d=d-2*w);
        }
    }
}

module spoked(d, w) {
    difference() {
        circle(d=d);
        spoke_holes(d, w);
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
    difference() {
        union() {
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
        cylinder(d=3, h=20, center=true);
    }
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

module notched_gear() {
    difference() {
        union() {
            linear_extrude(9)
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
            gear(60, 4, 1, 1.5, 25);
            translate([0,0,2])
            cube([4.4, 4.4, 4], center=true);
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

rotate(30)
translate([0,0,2])
driven_pegs(50, 2, 6, 3, 6);
translate([140/PI,0,9])
rotate(180)
mirror([0,0,1])
color("green")
notched_gear();

translate([0,0,2])
color("red") driving_spring(50, 1.8, 3);

color("blue") pegged_gear();

base();