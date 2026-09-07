# Working on ESPuino boxes

This repository holds per-box profiles and CAD. Firmware lives in a separate
ESPuino checkout. Read README.md and docs/espuino-build-guide.md first.

- Preserve tested hardware settings unless a change is explicitly required.
- Use a separate firmware checkout for each profile. Do not switch profiles in
  the user's active firmware tree: ignored overrides can persist between builds.
- `upstream.lock` records the tested source revision. Build validation alone is
  not hardware validation; do not advance the pin without hardware evidence.
- Never flash connected devices as part of documentation or build verification.
- Keep secrets, device/network identifiers, NVS dumps, audio and personal notes
  out of both files and commit history. Use a GitHub noreply author email for
  the public release when available.
- Run `bash -n deploy.sh` and `python3 tests/test_deploy.py` after script changes.
  Build affected profiles in isolated checkouts when configuration changes.
- Update docs/VALIDATION.md with the exact scope and limits of verification.
- CAD lives in case/first-pass. Geometry changes require regenerated exports;
  documentation/comment-only edits do not. Keep source and derived assets under
  the licensing and attribution described in NOTICE.md.
