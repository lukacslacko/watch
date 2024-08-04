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
            [-pressure_angle:2:2*pressure_angle]);
        mirror([1,0])
        rotate(-tooth_width_angle/2) involute_arc(
            pitch_diameter, pressure_angle, 
            [-pressure_angle:2:2*pressure_angle]);
    }
}

function d_outer(n_tooth, pitch=4, addendum=1) 
    = 2*addendum + pitch * n_tooth / PI;

module gear(
    n_tooth, 
    pitch=4, 
    addendum=1, dedendum=1.5, pressure_angle=25, d_inner=0
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

module spoked(d, w, d_inner=0) {
    difference() {
        circle(d=d);
        spoke_holes(d, w, d_inner);
    }
}

module wheel_and_pinion(n_wheel, n_pinion, h_wheel=2, h_pinion=6, h_axle=8, d_hole=3) {
    difference() {
        union() {
            linear_extrude(h_wheel) 
            gear(n_wheel, d_inner=d_outer(n_pinion));
            linear_extrude(h_pinion) 
            gear(n_pinion);
        }
        cylinder(d=d_hole, h=3*h_pinion, center=true);
    }
}
