# Measured parts and fit constraints

Dimensions below were recorded during fitting in July–August 2026. They describe
the actual components used, not guaranteed dimensions for every clone. Units: mm.
The OpenSCAD source is authoritative for the exported geometry.

| Component | Recorded dimensions / mount |
|---|---|
| Shell | 124 wide × 102 deep × 78 high; wall 3; floor 3 |
| Speaker | Body 27 × 31 × 15; overall width across tabs 44; two holes 37 apart |
| WS2812 ring | 12 pixels; outer diameter 50; inner diameter 35; height 2.6 |
| Buttons | 16mm panel holes |
| EC11 | 7mm bushing hole; anti-rotation tab notch retained |
| RC522 | PCB 60 × 39; thickness 1.6; mounting field 37 along board × 34 at pin end |
| PN5180 trial board | PCB 70 × 39; check the actual hole pattern and component clearance |
| USB-C breakout | PCB 21.5 × 12.5; holes diameter 3 at 16 centres; pilot row 2.5 from wall face |
| External microSD module | PCB 24 × 42; holes diameter 2 at 20 × 38 centres |
| V1 carrier (S3) | Mount centres 93 × 39; position adjusted for USB pigtail and amp overhang |
| V2 carrier (D32) | Mount centres 82 × 44; rear gap reserved for micro-USB pigtail |

V1's amplifier and wiring project about 15mm beyond the carrier's front edge.
The revised shell moves its carrier back 10mm. Clearances around the amplifier
and USB breakout are small; a different cable or terminal block may require
editing the model. V2 has its own post layout, without the external SD mount.

Use the top card slot with the 54mm edge of an ID-1-sized card horizontal.
Check thick labels/lamination as well as bare cards. Reliable reading and removal
detection depend on the reader, card, firmware settings and distance; mechanical
fit alone does not establish RFID performance.

Before adapting: measure PCB edges, hole centres, connector overhangs, component
heights and cable bend space. Print the fit coupon before the enclosure.
