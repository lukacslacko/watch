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

module gear(
    n_tooth, pitch, addendum, dedendum, pressure_angle, d_inner=0
) {
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
        spoke_holes(pitch_diameter - 2*dedendum, pitch, d_inner);
    }
}

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

module spoked(d, w) {
    difference() {
        circle(d=d);
        spoke_holes(d, w);
    }
}

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

module unpegged() {
    difference() {
        circle(d=50);
        for (a=[-0:10:60]) {
            rotate(a)
            translate([-140/PI,0])
            rotate(-30+a/6)
            translate([50-3/2,0]) #circle(d=3);
        }
    }
}

unpegged();

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

// demo();

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
