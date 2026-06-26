---
name: brainrender
description: >-
  Render or edit 3-D mouse-brain region figures with brainrender + vedo on the
  Allen atlas (e.g. notebooks/hedonic_hot_and_cold_spots.ipynb). Covers the repo
  .venv setup, brainrender's coordinate-frame quirks (k3d renderables vs vtk
  plotter; the scene.add pitfall), carving custom sub-regions from annotation
  voxels, hot/cold/uncertainty styling, and static labelled figures. Use whenever
  working with brainrender, vedo, brainglobe atlases, or these brain-viz notebooks.
---

# brainrender on the Allen mouse atlas

Practical notes for building brain-region figures in this repo. The worked example is
[notebooks/hedonic_hot_and_cold_spots.ipynb](../../../notebooks/hedonic_hot_and_cold_spots.ipynb).

## Environment

- brainrender is an optional "side-quest" dep in the repo `.venv` (Python 3.13).
  Install/refresh with `uv sync --group brain` (see `pyproject.toml` `[dependency-groups].brain`).
- Run the notebook with the `.venv` kernel.
- brainrender writes logs + downloads atlases to `~/.brainglobe`. The Claude **command
  sandbox blocks writes there**, so brainrender imports fail under the sandbox with
  `PermissionError: ... ~/.brainglobe`. Re-run such commands with the sandbox disabled
  (`dangerouslyDisableSandbox: true`). It works fine in the user's own Jupyter.
- Only `allen_mouse_50um` is downloaded by default. Finer atlases (`allen_mouse_25um`,
  `_10um`) download on first use (needs network) and give smoother meshes; voxel size is
  rarely the real limiter for these figures.

## Atlas axes

`allen_mouse_*` is brainglobe orientation `asr`, annotation array axes `(AP, SI, RL)` in µm:

- **x = AP**: anterior ≈ 0 → caudal ≈ 13200
- **y = SI**: dorsal = low → ventral = high
- **z = RL**: right ≈ 0 → left ≈ 11400, midline ≈ 5688

`atlas.annotation` is the label volume; `atlas.structures[acronym]["id"]`; descendants via
`atlas.get_structure_descendants(acronym)`. (`acronym in atlas.structures` is False for
acronyms — index by acronym instead of membership-testing.)

## The coordinate-frame trap (most important)

brainrender draws through two frames whose **left-right sign disagrees**:

| draw path | L-R sign | used by |
|---|---|---|
| `scene.renderables` | **+RL** (mirrored) | inline **k3d**: `vedo.Plotter().show(*scene.renderables, *meshes)` |
| `scene.plotter` actors | **−RL** | **vtk** pop-up + `scene.plotter.screenshot()` |

So a custom overlay mesh (built from atlas voxels, which are +RL) must be flipped to match
the path it is drawn through: **`flip_z = +1` for the k3d/renderables path, `flip_z = −1`
for the plotter/vtk path.** Get it wrong and the mesh appears mirrored *outside* the brain.

- Do **not** infer the sign from `scene.renderables[0]` (root) — root and the region meshes
  can carry opposite sign within one scene. Just pick the sign from the render path.
- Do **not** add custom meshes with `scene.add(mesh)`: it re-applies the orientation
  transform `(x,y,z) -> (z,y,-x)` and misplaces a mesh already in render space. Add to the
  plotter instead.
- `actor.center_of_mass()` returns *untransformed* coords; use `actor.bounds()` for the
  rendered frame.

## Carving custom sub-regions (atlas has no shell/core etc.)

The Allen atlas is not sub-parcellated (no NAc shell/core, no rostro-caudal splits). Build
sub-regions directly from annotation voxels and convert to a watertight surface:

```python
def region_mask(ac):
    ids = [atlas.structures[ac]["id"]] + [atlas.structures[a]["id"]
                                          for a in atlas.get_structure_descendants(ac)]
    return np.isin(ANN, ids)

def to_mesh(mask, flip_z, smooth=12):
    xs, ys, zs = np.where(mask); p = 2
    sl = tuple(slice(c.min()-p, c.max()+p+1) for c in (xs, ys, zs))
    origin = tuple(s.start*RES for s in sl)
    m = vedo.Volume(mask[sl].astype(float), spacing=(RES,)*3, origin=origin).isosurface(0.5)
    m = m.smooth(niter=smooth)
    v = m.vertices.copy(); v[:, 2] *= flip_z; m.vertices = v   # +1 k3d / -1 vtk
    m.compute_normals()
    return m
```

Select sub-voxels by normalised position (0..1) along each axis, e.g. a "rostrodorsal medial"
spot: `(ap < 0.42) & (si < 0.50) & (dist_from_midline <= 0.45*max)`. Keep the selection rules
as data (a list of dicts) so they are easy to tune against the source paper's verbal anatomy.

## Styling: difference + uncertainty

- Encode **category by hue** (red hot / blue cold) and **confidence by visual weight**:
  established = solid (`alpha≈0.95`), tentative = translucent (`alpha≈0.55`), potential =
  translucent + `mesh.wireframe(True)` (`alpha≈0.28`).
- Context structures: `scene.add_brain_region(ac, alpha=0.05, color="#888888", silhouette=False)`
  (pass `silhouette=False` to avoid k3d warnings; full hex like `#888888`, not `#888`).

## Three render paths

```python
# inline k3d (rotatable in Jupyter): renderables -> flip_z=+1
vedo.settings.default_backend = "k3d"
viewer = vedo.Plotter()                 # NB not `plt` (that is matplotlib)
viewer.show(*scene.renderables, *spots)

# vtk pop-up (full quality, blocks until 'q'/'Esc'): plotter -> flip_z=-1
vedo.settings.default_backend = "vtk"
for s in spots: scene.plotter.add(s)
scene.plotter.add(vedo.LegendBox([vedo.Sphere(r=1).c(col).legend(txt) for ...]))  # in-window legend
scene.plotter.show(interactive=True)

# static labelled figure (paper-style): screenshot + matplotlib legend underneath
scene.render(camera="sagittal", interactive=False)   # "frontal" = coronal
for s in spots: scene.plotter.add(s)
scene.plotter.screenshot(png); scene.close()
# then imshow(png) on top axis, ax.legend(handles=...) on a bottom axis
```

- Build a fresh scene per path (`Scene(...); add regions; build spots`) — cheap enough.
- For clean static figures: `Scene(title="", inset=False)` drops the baked title and the
  small orientation-inset blob; autocrop white margins from the PNG before `imshow`.
- Camera presets: `"frontal"` (coronal), `"sagittal"` (paper side view), `"top"`,
  `"three_quarters"`.

## Future direction for these notebooks

The end-product is a "liking → wanting → action" atlas driven by the brain-areas table at
`github.com/carlhenrikrolf/genaipedia.wiki`, with **connectivity** between highlighted areas
drawn as tubes/streamlines (brainrender cylinders/lines between centroids, or Allen
mouse-connectivity projection data).
