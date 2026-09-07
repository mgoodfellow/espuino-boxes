// SPDX-License-Identifier: GPL-3.0-only
// Parametric ESPuino enclosure; see ../README.md and ../../NOTICE.md.
// Select part = shell/top/cover/coupon for export; all is a preview.
// Select variant = v1 (S3) or v2 (D32); both is a legacy comparison only.
// Carrier mounts fit measured assemblies, not bare development boards.

part = "all";              // "coupon" | "top" | "shell" | "cover" | "all"

/* Shell VARIANT — one shell per build since 2026-07-16: the V1 board
   had to shift back 10mm (its MAX98357A overhangs the carrier front
   edge by ~15 — the y0=37 print didn't fit), which parks the shifted
   board on top of V2's back standoff row. So the posts fork:
     "v1"   -> V1 standoffs + left-wall SD mount   (s3-proto build)
     "v2"   -> V2 standoffs only                   (kidbox: SD onboard)
     "both" -> legacy shared shell (V2 back posts press on the shifted
               V1 board's solder side — preview/comparison only)      */
variant = "v1";            // "v1" | "v2" | "both"

/* ---- global fit ---------------------------------------------------- */
$fn        = 64;
clr        = 0.25;         // generic fit clearance (holes/pockets)

/* ---- box shell ----------------------------------------------------- */
box_w      = 124;          // X : left-right (was 116: grown 2026-07-10 so the
                           // 97mm carrier clears the corner posts — no clip)
box_d      = 102;          // Y : +Y FRONT, -Y BACK (was 96: grown for board
                           // runway + wire room)
box_h      = 78;           // Z : floor to wall top
wall       = 3;            // side wall thickness (rough box, not 7mm BioBox)
floor_t    = 3;

/* ---- top plate (flat lid) ------------------------------------------ */
top_t      = 3;
top_screw  = true;         // 4 corner M3 self-tap posts? (else friction)
lid_lip    = true;         // register lip under the lid -> drops into shell opening
lip_depth  = 5;            // how far the lip drops in
lip_t      = 2.0;          // lip wall thickness
lip_clear  = 0.5;          // gap to shell interior wall, per side (FIT KNOB)

/* ---- top-face layout (2026-07-07) ----------------------------
   +Y is the FRONT (speaker). Zones on the lid, front -> back:
     FRONT (+Y): 3 buttons spaced across
     CENTRE    : rotary encoder, dead-centre (0,0)
     BACK  (-Y): card slot -> card hangs by the RC522 on the back wall   */
n_buttons  = 3;            // three panel buttons; use the profile wiring table
btn_hole_d = 16.0;         // CONFIRMED: 16mm metal panel switch
btn_pitch  = 28;           // button centre-to-centre (X)
btn_y      = 28;           // button row toward FRONT (+Y, near the user)
enc_hole_d = 7.0;          // EC11 bushing ⌀7 (img 3); encoder at (0,0)
enc_tab    = true;         // keep the tab notch (harmless if the EC11 has no pin)
enc_tab_r  = 5.5;          // tab centre radius from shaft
enc_tab_d  = 2.4;

/* ---- card slot + full-height guide (Yoto-style) -------------------
   Slot near the BACK. A guide channel runs the FULL height of the shell
   (floor -> lid) so the card is captured the whole way down and can't miss
   the stop; its bottom rests at rest_z, setting how proud it stands. RC522
   sticky-pads to the back wall, coil facing the card ~1cm away (reads thru
   air). Card inserted PORTRAIT (54mm edge horizontal). Lid prints flat.   */
card_w     = 54.0;         // ISO ID-1 short edge -> slot opening width
card_t     = 0.76;         // card thickness
card_h     = 85.6;         // long edge (demo card only)
slot_w     = card_w + 3.0; // slot opening X (roomy: label wrap / edge wear)
slot_gap   = card_t + 1.2; // slot opening Y — takes a card with labels or
                           // laminate both sides (2026-07-10)
slot_y     = -42;          // slot centre near BACK (-Y): guide back face
                           // sits 3.3 off the rear wall (nothing lives
                           // behind it any more — the reader now rides the
                           // guide's FRONT face). Runway to the reader
                           // rails is ~81mm
guide_wall = 1.5;          // guide channel wall thickness
rest_z     = 20;           // card bottom rests here -> proud ~= rest_z+card_h-(box_h+top_t)
card_guide_on = true;
/* tower ends extend past the card zone as SOLID caps, each rising in a
   tab that drops into a pocket in the lid underside (2026-07-09):
   braces the tower top both ways + self-aligns lid slot to channel.  */
guide_end   = 7;           // solid end cap beyond the card zone (LEFT)
guide_end_r = 7;           // RIGHT cap (was 20 for pin-end rails; the
                           // reader's pin end is now held by a screw)
guide_tab_l = 5;           // brace tab length at each end
guide_tab_h = 1.6;         // tab rises above the wall top into the lid
guide_pock_d= 1.9;         // pocket depth in lid underside (1.1 skin above)

/* ---- main carrier boards, floor standoffs (2026-07-12) --------
   TWO stripboard variants; which standoff set prints is picked by
   `variant` (top of file) — shared-shell posts died 2026-07-16 when
   V1 shifted back onto V2's back row. All ⌀2 holes -> M2x6, 3.5 tall.

   V1 (s3-proto): ~97 x 49 rectangle, holes 93 x 39 c-c, plus an
     ~18mm speaker-wire overhang at the BACK-LEFT corner and the
     MAX98357A overhanging FORWARD off the front edge: 12 hard parts
     + ~3 speaker-cable exit = 15 envelope (caliper 2026-07-16; the
     y0=37 print hit the front wall).
     Moved back 10 -> front edge y32 (amp PCB nose y44, 4.0 off the
     wall — the last 1.0 is only cable envelope, and wire flexes;
     14-tall stack still ducks the speaker, which starts z24.5); back
     edge y-17, 1.25 clear of the USB breakout front corner (y-18.25).
     That's ALL the slack there is: the breakout can't retreat (its
     back corner y-39.75 sits 0.75 off the corner-boss web at y-40.5),
     so front-wall + breakout margins total 2.25 — split ~1/1.25. The
     back-left wire overhang ends y-35, ~5 clear of the guide face.
     Flashing USB-C pigtail STAYS PLUGGED on a SHORT edge: point it
     LEFT, under the SD module (which V1 uses). Plug adds 15 to the
     97 board (caliper, 2026-07-14) -> pattern sits +7 RIGHT of
     centre: 17.5 plug room left, 3.5 to the right wall.
     If print margins prove too thin: usbc_wall="left" would clear
     the breakout's X-zone off V1's right edge entirely (V1 left edge
     -41.5 vs left intrusion -46.5) and allow ~12mm shift with ~3mm
     margins — at the cost of the power cable exiting LEFT.
   V2 (kidbox): holes 82 x 44 c-c (board ~87 x 49), SD onboard, LOLIN
     across the middle overhanging 3 front / 7 back, terminal block
     6 out of one long edge, stack up to 30 TALL. First fit test
     (2026-07-14): set back 18 the plug did NOT fit — board now sits
     FORWARD at y0=37 (V1's old row before its 2026-07-16 shift;
     front edge ~8.5 off the wall,
     nose ducking the speaker, which starts z24.5), and the
     right-angle micro-USB lives in the ~30mm gap at the BACK,
     between the LOLIN and the card guide.
   Hole inset from board edges assumed 2.5 (V2) / 2 x 5 (V1) — nudge
   the x0/y0 pairs below if calipers disagree.                        */
main_pilot = 1.6;          // ⌀2 holes -> M2x6 self-tap
main_stand = 3.5;          // clears solder blobs under the stripboards
v1_mount_on = variant != "v2";
v1_x0      = -93/2 + 7;                  // = -39.5: +7 right of centre for
                                         // the 15mm USB-C pigtail (see above)
v1_y0      = 27;                         // was 37: back 10 for the amp
                                         // overhang (2026-07-16). Front edge
                                         // y32; back edge y-17, 1.25 off the
                                         // breakout corner — see block above
v1_cc_x    = 93;
v1_cc_y    = 39;
v2_mount_on = variant != "v1";
v2_x0      = 46.5 - 82;                  // = -35.5: fit-tested 2026-07-14
                                         // (was V1's front-right post until
                                         // V1 shifted +7 for its pigtail)
v2_y0      = 37;                         // V1's pre-shift row; plug gap
                                         // stays at the BACK (see above)
v2_cc_x    = 82;
v2_cc_y    = 44;

/* ---- explainer toggles (previews only; leave OFF for STL export) -- */
show_card  = false;        // draw a demo card in the slot
show_reader= false;        // draw a demo RC522 on the back inner wall
show_usb   = false;        // draw a demo USB-C breakout on its ledge
show_v1    = false;        // draw the V1 carrier (93x39, hugs front wall)
show_v2    = false;        // draw the V2 carrier (82x44, USB gap at back)
show_sd    = false;        // draw a demo microSD module on the left wall
show_spk   = false;        // draw a demo speaker box on its mount
show_ring  = false;        // draw a demo LED ring seated in its recess
show_cover = true;         // include the clear cover in "all"
show_lid   = true;         // include the lid in "all" (false = peek inside)
section    = false;        // slice at x=0 to reveal the card path

/* ---- USB-C port ---------------------------------------------------
   Breakout MEASURED (2026-07-09, holes re-measured 2026-07-13):
   board 21.5 x 12.5, holes ⌀3 at 16 c-c, centres 2.5mm behind the PCB
   edge / 4mm behind the port face (originally recorded 1mm — the first
   print proved that short); plug overhangs the board by 1.5mm. Lives on a SIDE wall: CONFIRMED it does NOT fit on
   the back wall. Board lies FLAT on a ledge, connector poking at the
   wall; 2x M3x8 self-tap down into the ledge. The plug face only
   reaches 1.5 into the 3mm wall, so the outside gets a 1.5-deep
   pocket the cable's shroud sinks into.                              */
usbc_wall  = "right";      // "left" | "right" — which side wall
usbc_pos   = -29;          // offset along that wall (Y). Near the back
                           // corner: clears BOTH carriers (V1 back edge
                           // y-17 vs breakout corner y-18.25; V2 terminal
                           // block — MEASURE the block's position, margin
                           // is thin); dupont fan passes under the reader
                           // rails. PINNED: can't go further back — the
                           // corner-boss web front face is y-40.5 and the
                           // board's back corner already sits at y-39.75
usbc_w     = 9.4;          // receptacle opening width
usbc_h     = 3.6;          // receptacle opening height
usbc_r     = 1.6;          // corner radius
usbc_z     = 12;           // centre height above floor (was 8: raised so the
                           // ledge under the board is deep enough for M3x8)
usb_w      = 21.5;         // board width (along the wall)
usb_d      = 12.5;         // board depth (into the box)
usb_hole_cc= 16;           // mounting hole c-c
usb_hole_inset = 2.5;      // hole centres from the interior wall face
                           // = 2.5 behind the PCB edge, 4 behind the port
                           // face (re-measured 2026-07-13 after the first
                           // print landed the pilots ~2mm too close to the
                           // wall; PCB edge sits at the interior face)
usb_pilot  = 2.6;          // ⌀3 holes -> M3 self-tap pilot
usb_board_t= 1.6;
usb_conn_mid = 1.6;        // receptacle centreline above the PCB top
usb_pocket_w = 13;         // exterior plug-shroud pocket ...
usb_pocket_h = 8;          //   (typical shroud ~12 x 6.5)
usb_pocket_d = 1.5;        // = plug overhang -> plug face lands flush

/* ---- RFID reader mount, FRONT face of the card guide (2026-07-12) --
   The guide moved back over the reader's old rear-wall home — and the
   reader's header pins point out of its COIL side anyway, so dupont
   connectors could never fit behind the guide. The reader now rides
   the guide's FRONT face: bare/solder side toward the guide (2.5mm
   blob gap), coil reading BACKWARD through its own PCB + the 1.5mm
   channel wall — card hangs ~7mm from the coil. Pins + duponts point
   forward into the open box.
   Board LANDSCAPE, drop-in from the top (2026-07-12: pin end is
   fully OPEN — 20mm duponts standing 5.5 proud and a crystal on the
   top edge mean nothing can lip over that end):
   - coil end: C-channel datum (clean edge; friction nub vs rattle);
   - pin end: M2x6 through the board's bottom pin-side ⌀3 hole into a
     boss; the top boss is piloted too (second screw optional). The hole
     field is IDENTICAL on RC522 and PN5180, so the same boss serves
     both readers — rfid_board only picks the demo preview length.    */
rfid_mount_on = true;
rfid_board = "rc522";      // "rc522" | "pn5180" — demo preview only
rfid_len   = rfid_board == "pn5180" ? 70 : 60;
rfid_h     = 39;           // both boards, landscape height
rfid_t     = 1.6;          // PCB thickness
rfid_cc_x  = 37;           // hole-field c-c along the board
rfid_cc_pin= 34;           // pin-side cross pair c-c (holes at cz +/- 17)
rfid_far_off = 7;          // far (coil-end) edge -> first hole centres
rfid_gap   = 4.0;          // gap to the guide face: blob room + keeps the
                           // M2 tip 1.1 short of the card channel
rfid_pilot = 1.6;          // boss pilot for the M2x6 (board hole is ⌀3)
rfid_cz    = 48;           // hole-field centre height ~= in-box card centre
rfid_pins_right = true;    // pin end toward +X

/* ---- microSD module mount, interior LEFT wall (2026-07-09) ----
   Module 24 x 42, holes ⌀2 at 20 x 38 c-c -> 4x M2x6 self-tap into
   3mm standoffs. Mounted LANDSCAPE (long edge horizontal): the cable
   couldn't make the bend at the bottom when the module was upright,
   so the pins now exit sideways along the wall.
   V1 builds only (V2 has SD onboard) — follows `variant`.            */
sd_mount_on = variant != "v2";
sd_cc_w    = 38;           // hole c-c along the wall (Y) — module long axis
sd_cc_h    = 20;           // hole c-c vertically (Z)
sd_pilot   = 1.6;          // ⌀2 holes -> M2 self-tap pilot
sd_stand   = 3;
sd_pos     = 0;            // module centre along the wall (Y)
sd_cz      = 40;           // module centre height

/* ---- speaker + LED ring (front wall, +Y) --------------------------- */
//  ALL CALIPER-MEASURED (2026-07-09): rectangular box speaker,
//  body 27(w) x 31(h) x 15(d), two side screw TABS -> 44 overall,
//  tab holes ⌀2 at 37 c-c on the horizontal centreline.
//  ring: OD 50, ID 35 (7.5 wide), 2.6 thick incl LEDs (clear 3).
spk_hole_d = 26;           // sound opening (body 27 wide -> keeps a rim)
spk_w      = 27;           // body width
spk_h      = 31;           // body height
spk_depth  = 15;           // body depth
spk_tab_span = 44;         // overall width across both screw tabs
spk_screw_pitch = 37;      // tab hole c-c (MEASURED)
spk_tab_setback = 6;       // tab contact plane behind the speaker FRONT face
spk_boss_d = 7;            // screw boss ⌀ on interior front wall
spk_boss_h = spk_tab_setback + 0.5;  // tabs on the boss faces -> speaker
                           // face floats 0.5 off the wall
spk_pilot  = 1.6;          // self-tap pilot for the ⌀2 tab holes
/* screws-only mount (2026-07-09): the old floor shelf is GONE to
   free the floor under the speaker for boards (~21mm headroom, plus
   ~11mm under the gusseted bosses). A small ledge just under the body
   remains as an assembly rest while driving the screws.             */
spk_ledge  = false;        // OFF (2026-07-12): it sliced as a floating
                           // shelf, and the tab screws hold the speaker
                           // fine — rest a finger under it instead
spk_ledge_d= 8;            // ledge depth off the wall (2 thick, body width)
ring_od    = 50.0;
ring_id    = 35.0;
ring_seat_od = ring_od + 1.5;   // seat ⌀ — was +1.0 and the first print needed trimming
ring_recess  = 4.3;        // ring+LEDs = 3 -> ~1.3mm spare under the cover
                           // (> bezel_h so the floor sits inside the wall)
ring_wire_w  = 12.0;       // wire cluster measured 11 -> 12 channel
ring_wire_top= true;            // open channel at TOP (12 o'clock) vs bottom
front_cx   = 0;            // speaker/ring centre X on front wall
front_cz   = 40;           // speaker/ring centre height above floor

/* ---- front bezel + clip-on clear cover (2026-07-09) -----------
   A round bezel stands proud of the front wall; the ring recess is cut
   deeper into wall+bezel (ring set back). A separate TRANSPARENT cap
   (part="cover") clips OVER the bezel: 3 snap nubs on its skirt drop
   into a relief groove at the bezel root. The cap face doubles as the
   speaker grill. Rotate the cap so no nub lands in the wire channel.  */
bezel_od   = 62;           // bezel ⌀ (chamfered front edge = snap lead-in)
bezel_h    = 4.0;          // proud of the front face (underside now tapers
                           // 45° into the wall — the straight disc bottom
                           // spaghettied on the 2026-07-13 print)
bezel_relief = 1.6;        // root relief depth (y) the nubs snap into
cover_t    = 1.6;          // cap face thickness
skirt_t    = 1.8;          // cap skirt wall
cover_clr  = 0.3;          // radial skirt-to-bezel clearance (FIT KNOB)
nub_d      = 2.2;          // snap nub (sphere), embedded 0.2 into skirt
grill_slot = 2.6;          // grill: concentric slot width over the speaker

/* ---- corner screw posts ------------------------------------------- */
post_od    = 7;
post_pilot = 2.6;          // M3 self-tap pilot
post_inset = 7;            // post centre inset from each corner

// =====================================================================
//  DERIVED
// =====================================================================
ix = box_w - 2*wall;
iy = box_d - 2*wall;
eps = 0.02;

post_xy = [ for (sx=[-1,1], sy=[-1,1])
              [ sx*(box_w/2 - post_inset), sy*(box_d/2 - post_inset) ] ];

function btn_x(i) = (i - (n_buttons-1)/2) * btn_pitch;

// =====================================================================
//  PRIMITIVES
// =====================================================================
module rrect(w,h,r){                       // rounded rectangle in XY
  hull() for (sx=[-1,1], sy=[-1,1])
    translate([sx*(w/2-r), sy*(h/2-r)]) circle(r=r);
}

module button_hole(){ cylinder(d=btn_hole_d, h=top_t+2); }

module usbc_cutout(){                       // opening + exterior plug pocket
  if (usbc_wall == "right"){
    translate([box_w/2 - wall - 1, usbc_pos, usbc_z])
      rotate([90,0,90]) linear_extrude(wall+2) rrect(usbc_w, usbc_h, usbc_r);
    translate([box_w/2 - usb_pocket_d, usbc_pos, usbc_z])
      rotate([90,0,90]) linear_extrude(usb_pocket_d+1)
        rrect(usb_pocket_w, usb_pocket_h, 2);
  } else {  // "left"
    translate([-box_w/2 + wall + 1, usbc_pos, usbc_z])
      rotate([90,0,-90]) linear_extrude(wall+2) rrect(usbc_w, usbc_h, usbc_r);
    translate([-box_w/2 + usb_pocket_d, usbc_pos, usbc_z])
      rotate([90,0,-90]) linear_extrude(usb_pocket_d+1)
        rrect(usb_pocket_w, usb_pocket_h, 2);
  }
}

module encoder_hole(){
  cylinder(d=enc_hole_d+clr, h=top_t+2);
  if (enc_tab)
    translate([enc_tab_r,0,0]) cylinder(d=enc_tab_d, h=top_t+2);
}

// =====================================================================
//  LID  (flat plate: buttons + encoder + card slot + register lip)
// =====================================================================
module lid_register(){
  // interrupted perimeter lip on the lid underside; drops into the shell
  // opening (ix x iy) to locate X & Y. 4 corner gaps clear the screw posts.
  xo   = box_w/2 - wall - lip_clear;                  // lip outer X
  yo   = box_d/2 - wall - lip_clear;                  // lip outer Y
  xlim = box_w/2 - post_inset - post_od/2 - 2;        // stop short of posts (X)
  ylim = box_d/2 - post_inset - post_od/2 - 2;        // stop short of posts (Y)
  // front & back bars (constrain Y)
  for (sy=[-1,1])
    translate([0, sy*(yo - lip_t/2), -lip_depth])
      linear_extrude(lip_depth) square([2*xlim, lip_t], center=true);
  // left & right bars (constrain X)
  for (sx=[-1,1])
    translate([sx*(xo - lip_t/2), 0, -lip_depth])
      linear_extrude(lip_depth) square([lip_t, 2*ylim], center=true);
}

module top_plate(){
  union(){
  difference(){
    translate([0,0,-eps]) linear_extrude(top_t) square([box_w, box_d], center=true);
    // encoder — dead centre
    translate([0,0,-1]) encoder_hole();
    // buttons — front row, spaced across
    for (i=[0:n_buttons-1]) translate([btn_x(i), btn_y, -1]) button_hole();
    // card slot — back
    translate([0, slot_y, -1])
      linear_extrude(top_t+2) square([slot_w, slot_gap], center=true);
    // pockets for the card-guide brace tabs (underside, either end)
    for (tx = [-(slot_w/2 + guide_end) + guide_tab_l/2,
                (slot_w/2 + guide_end_r) - guide_tab_l/2])
      translate([tx, slot_y, (guide_pock_d - 1)/2])
        cube([guide_tab_l + 0.6,
              slot_gap + 0.4 + 2*guide_wall + 0.6, guide_pock_d + 1],
             center=true);
    // corner screw clearance + counterbore
    if (top_screw)
      for (p = post_xy)
        translate([p[0], p[1], -1]){
          cylinder(d=3.4, h=top_t+2);               // M3 clearance
          translate([0,0,top_t-1.4+eps]) cylinder(d=6.2, h=2);  // head cbore
        }
  }
  if (lid_lip) lid_register();
  }
}

// =====================================================================
//  CARD GUIDE  (full-height channel, floor -> lid; bottom = card stop)
// =====================================================================
module card_guide(){
  gap = slot_gap + 0.4;               // channel width (Y) — card slides here
  gw  = guide_wall;                   // wall thickness each side
  ln  = slot_w;                       // card zone length (X)
  oy  = gap + 2*gw;                   // outer Y width
  x_l = -(ln/2 + guide_end);          // left end (short cap)
  x_r =  ln/2 + guide_end_r;          // right end (long cap: reader rails)
  translate([0, slot_y, 0])
    difference(){
      union(){
        // full-height block, floor -> under the lid
        translate([(x_l + x_r)/2, 0, box_h/2])
          cube([x_r - x_l, oy, box_h], center=true);
        // brace tabs on the end caps -> pockets in the lid underside
        for (tx = [x_l + guide_tab_l/2, x_r - guide_tab_l/2])
          translate([tx, 0, box_h + guide_tab_h/2 - eps])
            cube([guide_tab_l, oy, guide_tab_h + eps], center=true);
      }
      // channel: card zone only — the end caps stay solid
      translate([0,0, rest_z + (box_h-rest_z)/2 + 0.5])
        cube([ln, gap, box_h-rest_z+2], center=true);
    }
}

// =====================================================================
//  DEMO PARTS + SECTION  (previews only)
// =====================================================================
module demo_card(){
  color("SkyBlue")
    translate([-card_w/2, slot_y - card_t/2, rest_z])
      cube([card_w, card_t, card_h]);
}

module demo_reader(){                        // landscape board on the guide
  s  = rfid_pins_right ? 1 : -1;
  fx = -s*(rfid_cc_x/2 + rfid_far_off);
  yb = slot_y + (slot_gap + 0.4)/2 + guide_wall + rfid_gap;
  color("RoyalBlue")
    translate([min(fx, fx + s*rfid_len), yb, rfid_cz - rfid_h/2])
      cube([rfid_len, rfid_t, rfid_h]);
}

module demo_sd(){                            // 42x24 microSD module, landscape
  color("MediumPurple")
    translate([-box_w/2 + wall + sd_stand, sd_pos - 21, sd_cz - 12])
      cube([1.6, 42, 24]);
}

module demo_v1(){                            // V1: rectangle + back-left tab
  fx = v1_x0 - 2;                            // board left edge (inset 2)
  fy = v1_y0 + 5;                            // board front edge (inset 5)
  color("Peru"){
    translate([fx, fy - 49, floor_t + main_stand])
      cube([97, 49, 1.6]);                   // main body, floating
    translate([fx, fy - 49 - 18, floor_t + main_stand])
      cube([25, 18 + eps, 1.6]);             // speaker-wire overhang
    translate([fx + 8, fy - eps, floor_t + main_stand + 1.6])
      cube([20, 15 + eps, 1.6]);             // MAX98357A: 12 board + 3 cable
                                             // exit = 15 envelope (x-pos
                                             // approx — left third, 07-16)
  }
  color("DimGray")                           // USB-C pigtail, stays plugged
    translate([fx - 15, fy - 49/2 - 5, floor_t + main_stand + 1.6])
      cube([15 + eps, 10, 7]);
}

module demo_v2(){                            // V2: forward, plug gap at BACK
  fx = v2_x0 - 2.5;                          // board left edge (inset 2.5)
  fy = v2_y0 + 2.5;                          // board front edge (inset 2.5)
  bx = fx + 87/2;                            // board centre X
  color("Chocolate"){
    translate([fx, fy - 49, floor_t + main_stand])
      cube([87, 49, 1.6]);                   // main body
    translate([bx - 25/2, fy - 49 - 7, floor_t + main_stand])
      cube([25, 49 + 3 + 7, 1.6]);           // LOLIN: +3 front / +7 back
    translate([fx + 87, fy - 49 + 1, floor_t + main_stand])
      cube([6, 10, 1.6]);                    // terminal block, right edge
  }
}

module demo_usb(){                           // breakout flat on its ledge
  m  = (usbc_wall == "right") ? 1 : -1;
  ixf= m*(box_w/2 - wall);
  bt = usbc_z - usb_conn_mid;                // board TOP z
  color("Crimson")
    translate([min(ixf, ixf - m*usb_d), usbc_pos - usb_w/2, bt - usb_board_t])
      cube([usb_d, usb_w, usb_board_t]);
}

module demo_speaker(){                       // box speaker + side tabs
  color("DarkOliveGreen"){
    translate([front_cx - spk_w/2,
               box_d/2 - wall - (spk_boss_h - spk_tab_setback) - spk_depth,
               front_cz - spk_h/2])
      cube([spk_w, spk_depth, spk_h]);
    for (sx=[-1,1])
      translate([front_cx + (sx<0 ? -spk_tab_span/2 : spk_w/2),
                 box_d/2 - wall - spk_boss_h - 1.5, front_cz - 5])
        cube([(spk_tab_span - spk_w)/2, 1.5, 10]);
  }
}

module demo_ring(){                          // LED ring seated in the recess
  color("DimGray")                           // (+0.15: preview z-fight dodge)
    translate([front_cx, box_d/2 + bezel_h - ring_recess + 0.15, front_cz])
      rotate([-90,0,0])
        difference(){
          cylinder(d=ring_od, h=3);
          translate([0,0,-1]) cylinder(d=ring_id, h=5);
        }
}

module full_assembly(){
  shell();
  if (show_lid) color("SlateGray") translate([0,0,box_h]) top_plate();
  if (show_cover)
    color("LightCyan", 0.35)
      translate([front_cx, box_d/2 + bezel_h + cover_t, front_cz])
        rotate([90,0,0]) ring_cover();
  if (show_card)   demo_card();
  if (show_reader) demo_reader();
  if (show_usb)    demo_usb();
  if (show_v1)     demo_v1();
  if (show_v2)     demo_v2();
  if (show_sd)     demo_sd();
  if (show_spk)    demo_speaker();
  if (show_ring)   demo_ring();
}

module section_cut(){                        // keep x<0 half
  difference(){ children(); translate([0,-250,-350]) cube([300,500,700]); }
}

// =====================================================================
//  CORNER SCREW BOSS  (post gusseted into the two corner walls)
// =====================================================================
module corner_boss(sx, sy){
  cx = box_w/2 - wall;                 // inner X wall face (magnitude)
  cy = box_d/2 - wall;                 // inner Y wall face (magnitude)
  px = sx*(box_w/2 - post_inset);      // screw centre (matches lid holes)
  py = sy*(box_d/2 - post_inset);
  difference(){
    translate([0,0,floor_t])
      linear_extrude(box_h - floor_t)
        hull(){                        // post body + webs tying it to both walls
          translate([px, py]) circle(d=post_od);
          translate([sx*(cx-0.5), py]) square([1, post_od], center=true);   // -> X wall
          translate([px, sy*(cy-0.5)]) square([post_od, 1], center=true);   // -> Y wall
        }
    translate([px, py, box_h-12]) cylinder(d=post_pilot, h=14);             // M3 pilot
  }
}

// =====================================================================
//  SHELL  (floor + 4 walls, open top)
// =====================================================================
module bezel(){
  // proud ring on the front face; chamfered outer edge = snap lead-in.
  // Underside rises at 45° from the root: the straight disc's bottom
  // crescent printed on air and spaghettied (2026-07-13). The cover
  // skirt shows a small crescent gap over this chamfer — rotate the
  // cap so no snap nub lands there (or in the wire channel).
  difference(){
    translate([front_cx, box_d/2 - eps, front_cz]) rotate([-90,0,0]){
      cylinder(d=bezel_od, h=bezel_h - 1.2 + eps);
      translate([0,0,bezel_h - 1.2])
        cylinder(d1=bezel_od, d2=bezel_od - 2.4, h=1.2);
    }
    // 45° wedge: keep z >= bezel bottom + distance off the wall face
    translate([front_cx, box_d/2, front_cz - bezel_od/2])
      rotate([45,0,0]) translate([-100,-150,-300]) cube([200,300,300]);
  }
}

module front_cutouts(){
  translate([front_cx, 0, front_cz]){
    // speaker sound hole, straight through wall + bezel web
    translate([0, box_d/2 - wall - 1, 0])
      rotate([-90,0,0]) cylinder(d=spk_hole_d, h=wall + bezel_h + 2);
    // LED-ring seat: flat-floored pocket, ring_recess deep from bezel face
    translate([0, box_d/2 + bezel_h + eps, 0])
      rotate([90,0,0]) cylinder(d=ring_seat_od, h=ring_recess + eps);
    // OPEN wire channel (2026-07-09: wider + open — ring drops in
    // with wires soldered): radial slot from inside the seat rim out to
    // the bezel edge, cut through the FULL wall+bezel depth
    translate([-ring_wire_w/2, box_d/2 - wall - 1,
               ring_wire_top ? ring_od/2 - 4 : -(bezel_od/2 - 1)])
      cube([ring_wire_w, wall + bezel_h + 2,
            (bezel_od/2 - 1) - (ring_od/2 - 4)]);
    // bezel root relief — the groove the cover's snap nubs drop into.
    // Stops short of the bottom arc: there it would undercut the
    // chamfered underside into a floating sliver (no nub can seat over
    // the chamfer gap anyway).
    translate([0, box_d/2 - eps, 0])
      rotate([-90,0,0])
        difference(){
          cylinder(d=bezel_od + 1, h=bezel_relief + eps);
          translate([0,0,-1]) cylinder(d=bezel_od - 2.4, h=bezel_relief + 2);
          translate([-50, bezel_od/2 - 4.6, -2])   // local +y = box DOWN
            cube([100, 60, bezel_relief + 4]);
        }
  }
}

// --- speaker mount: 2 gusseted screw bosses (screws do the holding) --
//     Tabs on the boss faces, M2x6. Each boss has a tapered web down
//     the wall for stiffness; the floor below stays clear for boards.
//     Optional slim ledge = assembly rest while driving the screws.
module speaker_mount(){
  iyf = box_d/2 - wall;                  // interior front wall face (y)
  for (sx=[-1,1]){
    px = front_cx + sx*spk_screw_pitch/2;
    difference(){
      hull(){
        translate([px, iyf + eps, front_cz])
          rotate([90,0,0]) cylinder(d=spk_boss_d, h=spk_boss_h + eps);
        translate([px - spk_boss_d/2, iyf - 1.5, front_cz - 12])
          cube([spk_boss_d, 1.5 + eps, 12]);   // gusset root on the wall
      }
      translate([px, iyf - spk_boss_h - eps, front_cz])
        rotate([-90,0,0]) cylinder(d=spk_pilot, h=spk_boss_h + 1.5);
    }
  }
  if (spk_ledge)
    translate([front_cx - (spk_w + 4)/2, iyf - spk_ledge_d,
               front_cz - spk_h/2 - 2])
      cube([spk_w + 4, spk_ledge_d, 2]);
}

// --- RFID mount, FRONT face of the card guide -------------------------
//     Coil-end C-channel (drop-in from the top, stops at z=72.5 under
//     the lid lip) + one screw boss and one rest pad behind the
//     pin-side holes. Pin end is otherwise fully open for the dupont
//     fan and the top-edge crystal.
module rfid_rail(xe, s_in){
  // xe: board end-edge x; s_in: +1 if the board extends toward +X
  ytf = slot_y + (slot_gap + 0.4)/2 + guide_wall;  // guide FRONT face
  yb  = ytf + rfid_gap;                // board BACK face plane
  zb  = rfid_cz - rfid_h/2;            // board bottom edge
  x0  = xe - s_in*3.2;                 // outer face of the rail block
  difference(){
    // block: rib (guide->board) + end wall + front lip, one solid
    translate([min(x0, xe + s_in*2.8), ytf - eps, zb - 2.2])
      cube([6, rfid_gap + rfid_t + 2.0 + eps, 72.5 - (zb - 2.2)]);
    // board slot: 0.2 end clearance, thickness + 0.4
    translate([min(xe - s_in*0.2, xe + s_in*3.8), yb - 0.2, zb])
      cube([4, rfid_t + 0.4, 80]);
  }
  // taper the block's underside into the guide face (printability)
  hull(){
    translate([min(x0, xe + s_in*2.8), ytf - eps, zb - 2.2])
      cube([6, rfid_gap + rfid_t + 2.0 + eps, 1]);
    translate([min(x0, xe + s_in*2.8), ytf - eps, zb - 2.2 - 7])
      cube([6, 1 + eps, 1]);
  }
  // friction nub on the lip
  translate([xe + s_in*1.4, yb + rfid_t + 0.7, 62]) sphere(d=1.8);
}

module rfid_mount(){
  s   = rfid_pins_right ? 1 : -1;
  ytf = slot_y + (slot_gap + 0.4)/2 + guide_wall;
  rfid_rail(-s*(rfid_cc_x/2 + rfid_far_off), s);   // coil-end datum
  // pin-side: screw bosses behind BOTH cross holes; 0.5 skin to the
  // channel. Bottom screw is THE screw; the top one is optional (the
  // crystal rides the board's top edge — skip it unless the board
  // rattles), but a bare pad just looked like a missing hole on the
  // print. Both taper down into the guide face for printability.
  for (sz=[-1,1])
    difference(){
      hull(){
        translate([s*rfid_cc_x/2, ytf - eps, rfid_cz + sz*rfid_cc_pin/2])
          rotate([-90,0,0]) cylinder(d=6, h=rfid_gap + eps);
        translate([s*rfid_cc_x/2 - 3, ytf - eps,
                   rfid_cz + sz*rfid_cc_pin/2 - 10])
          cube([6, 1.2 + eps, 10]);
      }
      translate([s*rfid_cc_x/2, ytf + rfid_gap + eps,
                 rfid_cz + sz*rfid_cc_pin/2])
        rotate([90,0,0]) cylinder(d=rfid_pilot, h=rfid_gap + 1.0);
    }
}

// --- microSD module standoffs, interior left wall --------------------
module sd_mount(){
  ixl = -box_w/2 + wall;               // interior left wall face
  for (sy=[-1,1], sz=[-1,1])
    difference(){
      hull(){   // standoff + taper down into the wall (printability)
        translate([ixl - eps, sd_pos + sy*sd_cc_w/2, sd_cz + sz*sd_cc_h/2])
          rotate([0,90,0]) cylinder(d=5, h=sd_stand + eps);
        translate([ixl - eps, sd_pos + sy*sd_cc_w/2 - 2.5,
                   sd_cz + sz*sd_cc_h/2 - 8])
          cube([1 + eps, 5, 8]);
      }
      translate([ixl + sd_stand + eps, sd_pos + sy*sd_cc_w/2, sd_cz + sz*sd_cc_h/2])
        rotate([0,-90,0]) cylinder(d=sd_pilot, h=sd_stand + 2);
    }
}

// --- carrier-board standoff template (4 posts per pattern) -----------
module board_mount(x0, y0, cc_x, cc_y){
  for (ix=[0,1], iy=[0,1])
    difference(){
      translate([x0 + ix*cc_x, y0 - iy*cc_y, floor_t - eps])
        cylinder(d=6, h=main_stand + eps);
      translate([x0 + ix*cc_x, y0 - iy*cc_y, floor_t - 2 + eps])
        cylinder(d=main_pilot, h=main_stand + 2);
    }
}

// --- USB breakout ledge, under the side-wall cutout -------------------
//     Board lies flat, connector at the wall; 2x M3x8 straight down
//     through the ⌀3 holes into the ledge. Pilots sit usb_hole_inset
//     off the wall; ledge is deep enough to keep material past them.
module usb_ledge(){
  m   = (usbc_wall == "right") ? 1 : -1;
  ixf = m*(box_w/2 - wall);            // interior face of that wall
  ld  = usb_hole_inset + usb_pilot/2 + 2;      // ledge depth into the box
  lt  = usbc_z - usb_conn_mid - usb_board_t;   // ledge top = board underside
  difference(){
    translate([min(ixf, ixf - m*ld), usbc_pos - usb_w/2 - 1, floor_t - eps])
      cube([ld, usb_w + 2, lt - floor_t + eps]);
    for (sy=[-1,1])
      translate([ixf - m*usb_hole_inset, usbc_pos + sy*usb_hole_cc/2, lt + eps])
        rotate([180,0,0]) cylinder(d=usb_pilot, h=lt - 1);
  }
}

module shell(){
  difference(){
    union(){
      translate([0,0,box_h/2]) cube([box_w, box_d, box_h], center=true);
      bezel();
    }
    translate([0,0,floor_t + box_h/2]) cube([ix, iy, box_h], center=true);

    // --- USB-C cutout (side wall — back wall confirmed too tight) ---
    usbc_cutout();

    // --- speaker hole + ring seat + wire channel + snap relief ---
    front_cutouts();
  }

  // --- corner screw bosses, gusseted into the walls ---
  if (top_screw)
    for (sx=[-1,1], sy=[-1,1]) corner_boss(sx, sy);

  // --- full-height card guide rising from the floor ---
  if (card_guide_on) card_guide();

  // --- speaker shelf + screw bosses on the front wall ---
  speaker_mount();

  // --- board mounts: RFID (back), microSD (left), USB ledge (side) ---
  if (rfid_mount_on) rfid_mount();
  if (sd_mount_on)   sd_mount();      // V1 builds (V2 has SD onboard)
  if (v1_mount_on) board_mount(v1_x0, v1_y0, v1_cc_x, v1_cc_y);
  if (v2_mount_on) board_mount(v2_x0, v2_y0, v2_cc_x, v2_cc_y);
  usb_ledge();
}

// =====================================================================
//  CLEAR COVER  (separate print, transparent filament, face DOWN)
//  Cap face = LED window + speaker grill; skirt clips over the bezel,
//  3 nubs snap into the root relief. Pops off with a fingernail.
// =====================================================================
module ring_cover(){
  cod = bezel_od + 2*(cover_clr + skirt_t);   // cap outer ⌀
  sid = bezel_od + 2*cover_clr;               // skirt inner ⌀
  difference(){
    union(){
      cylinder(d=cod, h=cover_t);                          // face
      difference(){                                        // skirt
        cylinder(d=cod, h=cover_t + bezel_h - 0.3);
        translate([0,0,-1]) cylinder(d=sid, h=cover_t + bezel_h + 2);
      }
    }
    // speaker grill: concentric slots + 4 spokes, over the sound hole
    for (r=[4.5, 8.5, 12.5])
      difference(){
        translate([0,0,-1]) cylinder(r=r + grill_slot/2, h=cover_t + 2);
        translate([0,0,-1.5]) cylinder(r=r - grill_slot/2, h=cover_t + 3);
        for (a=[45,135,225,315]) rotate([0,0,a])
          translate([0,-1.9,-2]) cube([r + grill_slot/2 + 1, 3.8, cover_t + 4]);
      }
  }
  // 3 snap nubs — rotate the cap so none sits in the wire channel (top)
  // or over the bezel's chamfered underside (bottom ~±30°)
  for (a=[30,150,270]) rotate([0,0,a])
    translate([sid/2 + 0.2, 0, cover_t + bezel_h - bezel_relief/2])
      sphere(d=nub_d);
}

// =====================================================================
//  FIT-TEST COUPON  (~62 x 46: 1 button, encoder, USB-C, 1 post)
//  Print this FIRST — 15 min, confirms every hole size before the shell.
// =====================================================================
module coupon(){
  cw = 62; ch = 46;
  difference(){
    union(){
      translate([0,0,-eps]) linear_extrude(top_t) square([cw,ch], center=true);
      translate([0, ch/2 - wall, 0]) cube([cw, wall, usbc_z+usbc_h/2+3]);
    }
    translate([-14, 6, -1]) button_hole();
    translate([ 14, 6, -1]) encoder_hole();
    translate([0, ch/2 + 1, usbc_z])
      rotate([90,0,0]) linear_extrude(wall+2) rrect(usbc_w, usbc_h, usbc_r);
  }
  translate([0, -12, -eps])
    difference(){
      cylinder(d=post_od, h=6);
      translate([0,0,-1]) cylinder(d=post_pilot, h=8);
    }
}

// =====================================================================
//  RENDER SELECT
// =====================================================================
if (part == "shell")  shell();
else if (part == "top")    top_plate();
else if (part == "cover")  ring_cover();
else if (part == "coupon") coupon();
else {                                   // "all"
  if (section) section_cut() full_assembly();
  else full_assembly();
}
