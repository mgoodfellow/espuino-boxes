# Printable enclosure

A parametric OpenSCAD enclosure with a top card slot, three 16mm buttons, EC11
encoder, speaker and 12-pixel ring. The outer shell is 124 × 102 × 78mm before
the lid and projecting cover. See [measured parts](MEASUREMENTS.md).

![Assembly CAD preview](first-pass/rough-box-all.png)

This is a practical first-pass case fitted around two specific perfboard
assemblies. Measure your parts and slice/check the model before printing.
Preview images include development views; use the selected STL and source for
actual geometry. The carrier mount patterns are not bare ESP32 board footprints.

## Files to print

| Part | File | Quantity |
|---|---|---|
| S3 shell, V1 carrier and separate SD mount | [rough-box-shell-v1.stl](first-pass/rough-box-shell-v1.stl) | 1 for S3 |
| D32 shell, V2 carrier and onboard SD | [rough-box-shell-v2.stl](first-pass/rough-box-shell-v2.stl) | 1 for D32 |
| Common lid | [rough-box-top.stl](first-pass/rough-box-top.stl) | 1 |
| Speaker/ring cover | [rough-box-cover.stl](first-pass/rough-box-cover.stl) | 1 |
| Fit coupon | [rough-box-coupon.stl](first-pass/rough-box-coupon.stl) | Print first |
| Optional RC522 offset adapter | [shim instructions](first-pass/rc522-8mm-offset-shim.md) | As needed |

Use translucent material for the cover if you want light through it. Check
orientation, overhangs, wall strength and clearances in your slicer; no universal
printer/material profile is supplied. Check card insertion and RFID reading
before committing to the full assembly.

## Editing and exporting

Open [rough-box.scad](first-pass/rough-box.scad) in OpenSCAD. Select
`part="shell"`, `"top"`, `"cover"` or `"coupon"`; for a shell select
`variant="v1"` (S3) or `"v2"` (D32). Render (F6), then export STL.
`part="all"` is an assembly preview. `variant="both"` is a legacy comparison
layout whose posts interfere with the revised V1 carrier; do not print it for a box.

The [RC522 shim source](first-pass/rc522-8mm-offset-shim.scad) exports separately.
Its offset is adjustable from 8 to 10mm; the supplied STL uses 8mm. It is an
optional retrofit, not a required part of every build.

## Assembly

1. Print the coupon and confirm screw/panel-component fits.
2. Print the appropriate shell, lid and cover.
3. Fit USB breakout, carrier and speaker with the [listed fasteners](first-pass/FIXINGS.md).
4. Slide the RC522 into the coil-end rail and secure its pin end. Use the shim
   instructions if increasing the reader-to-card gap.
5. Route wiring away from screw holes, the card guide and moving controls.
6. Test playback, controls and reliable card reading/removal before closing the lid.

These are hobby enclosure files, not a certified child-safe product. Check that
fasteners, small parts and low-voltage wiring are secured for the intended user.
See [credits and provenance](../NOTICE.md).
