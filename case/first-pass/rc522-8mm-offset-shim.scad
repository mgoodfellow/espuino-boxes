// SPDX-License-Identifier: GPL-3.0-only
// See ../../NOTICE.md and ../../LICENSE.
// RC522 retrofit offset carrier for rough-box.scad.
//
// The 1.6 mm base is a dummy RC522 PCB: it drops into the enclosure's
// existing coil-end C-rail and lands on the existing pin-side bosses. A
// second C-rail and an upper spacer boss hold the RC522 8 mm farther into
// the enclosure.
//
// Two M2x6 screws are fitted in sequence: lower hole from shim to enclosure,
// then upper hole from RC522 to shim. Print with the dummy PCB flat.

$fn = 32;

// Match the RFID mount dimensions in rough-box.scad.
board_len       = 60;
board_h         = 39;
board_t         = 1.6;
board_hole_cc_x = 37;
board_hole_cc_z = 34;
board_far_off   = 7;
board_cz        = 48;

offset          = 8;       // supported range: 8-10 mm
m2_clearance    = 2.4;
m2_pilot        = 1.6;

board_coil_x = -(board_hole_cc_x/2 + board_far_off);
board_pin_x  = board_hole_cc_x/2;
board_bottom = board_cz - board_h/2;
board_top    = board_cz + board_h/2;
lower_hole_z = board_cz - board_hole_cc_z/2;
upper_hole_z = board_cz + board_hole_cc_z/2;
eps          = 0.02;

module y_hole(d, length) {
  // Cylinder starts at the caller's y coordinate and cuts toward -Y.
  rotate([90, 0, 0]) cylinder(d=d, h=length);
}

module dummy_board() {
  difference() {
    translate([board_coil_x, 0, board_bottom])
      cube([board_len, board_t, board_h]);

    // Lower M2x6 screw fixes the dummy PCB to the enclosure's lower boss.
    translate([board_pin_x, board_t + eps, lower_hole_z])
      y_hole(m2_clearance, board_t + 2*eps);
  }
}

module upper_reader_standoff() {
  pilot_depth = 4.8;

  difference() {
    // Upper RC522 hole gets the same 6 mm boss as the original mount.
    translate([board_pin_x, 0, upper_hole_z])
      rotate([-90, 0, 0]) cylinder(d=6, h=offset);

    // Upper M2x6 screw self-taps into the shim after the RC522 is inserted.
    translate([board_pin_x, offset + board_t + eps, upper_hole_z])
      y_hole(m2_pilot, board_t + pilot_depth + 2*eps);
  }
}

module shifted_coil_rail() {
  rail_x0     = board_coil_x - 3.2;
  rail_w      = 6;
  rail_back   = 2;
  rail_bottom = board_bottom - 2.2;
  rail_top    = 72.5;
  rail_h      = rail_top - rail_bottom;
  spine_x     = board_coil_x + 3.5; // clears the old rail's inner edge
  spine_w     = 3;

  union() {
    difference() {
      // Back, end wall and front lip form the new drop-in C-channel.
      translate([rail_x0, offset - rail_back, rail_bottom])
        cube([rail_w, rail_back + board_t + 2, rail_h]);

      // 0.2 mm clearance around the RC522 edge and PCB thickness.
      translate([board_coil_x - 0.2, offset - 0.2, board_bottom])
        cube([4, board_t + 0.4, board_h + 10]);
    }

    // A narrow full-height spine rises from the dummy PCB just beyond the
    // old C-rail. The short back flange joins it to the shifted C-channel.
    translate([spine_x, board_t - eps, rail_bottom])
      cube([spine_w, offset - board_t + eps, rail_h]);
    translate([rail_x0, offset - rail_back, rail_bottom])
      cube([spine_x + eps - rail_x0, rail_back, rail_h]);

    // Match the original rail's light anti-rattle pressure on the PCB edge.
    translate([board_coil_x + 1.4, offset + board_t + 0.7, 62])
      sphere(d=1.8);
  }
}

module shim() {
  dummy_board();
  shifted_coil_rail();
  upper_reader_standoff();
}

// Rotate the installed orientation so the dummy-PCB plane prints flat.
rotate([90, 0, 0]) shim();
