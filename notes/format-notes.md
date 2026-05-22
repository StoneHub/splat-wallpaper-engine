# Format Notes

## Preferred Runtime

Use `.sog` for the first runtime path.

Reasons:

- Compact enough for wallpaper use.
- Already used in Monroe's splat publishing workflow.
- Supported by PlayCanvas/SuperSplat tooling.

## Source Files

Keep `.ply` as source/archive. A usable Gaussian Splat PLY should include splat-specific properties such as:

- `scale_0`
- `rot_0`
- `opacity`
- `f_dc_0`

If those fields are missing, the file is probably a mesh PLY or sparse point-cloud PLY, not a renderable Gaussian splat.

## Candidate Conversion

```bash
splat-transform input.ply output.sog
```

SuperSplat's web converter can also convert between `.ply`, `.sog`, `.ksplat`, `.splat`, and `.spz`.

