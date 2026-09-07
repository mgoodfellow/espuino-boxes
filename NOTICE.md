# License and attribution

The files distributed in this repository are licensed under GNU GPL version 3
(`GPL-3.0-only`); the full license is in [LICENSE](LICENSE). This includes the
configuration, deployment tooling, documentation and enclosure source/exports.
Existing third-party copyright notices remain applicable. No warranty is provided.

## ESPuino

The configuration headers under `boxes/` are modified from
[ESPuino](https://github.com/biologist79/ESPuino), copyright its contributors,
under the GNU GPL v3. The profiles adapt feature settings, memory configuration
and pin assignments for the documented hardware. Modifications were made in
2026; the public-release preparation is dated 2026-09-07.

The deployment script and original project material are copyright (c) 2026
Mike Goodfellow and contributors. Firmware itself is obtained separately from
the linked ESPuino repository at the revision in each `upstream.lock`.
Firmware libraries retain their own licenses; they are not vendored here.

## Enclosure provenance

The repository's development history records `case/first-pass/rough-box.scad`
as a separate first-pass OpenSCAD enclosure, with dimensions subsequently
adjusted to measured components and printed fit tests. It is distinct from the
proposed Fusion-based BioBox adaptation in the early planning notes. The shipped
OpenSCAD sources are self-contained, with no imported donor geometry; the STL
files and preview renders are exports of this project's enclosure work.

Credit for design inspiration and community reference material:

- [BioBox 3D by biologist](https://forum.espuino.de/t/biobox-3d/3130).
- [BioBox 3D modification by BlackYeti](https://forum.espuino.de/t/modifikation-biobox-3d/3571).

Those external CAD downloads are not distributed here. This repository's license
does not grant rights to them. Check the original author's terms before reusing
external models. The RC522 offset adapter is supplied as separate editable
OpenSCAD source with its STL export.
