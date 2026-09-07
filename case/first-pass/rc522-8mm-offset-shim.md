# RC522 8 mm offset shim

`rc522-8mm-offset-shim.stl` is a dummy-RC522 adapter for the existing
`rough-box` RFID mount. Its 60 x 39 x 1.6 mm base fits where the RC522 fitted,
then provides a new C-rail and upper mounting boss 8 mm farther into the
enclosure. The lower hole fixes the adapter to the box; the upper hole fixes
the RC522 to the adapter.

## Fitment

- Fits the existing coil-end C-rail and lower pin-side RFID boss.
- Supports the 60 x 39 mm RC522 and its 37 x 34 mm hole field.
- The SCAD `offset` can be set from 8 to 10 mm.
- Uses two standard M2x6 screws; no long screws are required.

## Installation

1. Remove the RC522 and its existing pin-side screws.
2. Drop the adapter's dummy-PCB edge into the existing coil-end C-rail.
3. Fasten the adapter's lower hole to the enclosure's lower boss with an M2x6 screw.
4. Drop the RC522 into the adapter's new C-rail.
5. Fasten the RC522's upper hole to the adapter's upper standoff with an M2x6 screw.

The STL is oriented with the dummy PCB flat for support-free printing.
