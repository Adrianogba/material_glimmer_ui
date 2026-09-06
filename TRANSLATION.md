# Translation notes

A file-by-file comparison against the `androidx.xr.glimmer` sources, kept so the
claims in the README stay checkable and so the next person can see what was
decided and why.

The sources live at
[`xr/glimmer`](https://android.googlesource.com/platform/frameworks/support/+/androidx-main/xr/glimmer/)
in the AndroidX tree. `tool/fetch_reference.py` mirrors them into
`reference/`, which is neither committed nor published: that code is Google's
under Apache 2.0, and this package is MIT.

## Taken verbatim

| Upstream | Here | Value |
|---|---|---|
| `Colors` | `GlimmerColors` | `#9BBFFF`, `#4C88E9`, `#63FEA8`, `#FFA7A0`, surface `#303030`, background black |
| `ContentColor` | `GlimmerColors.contentColorFor` | luminance breakpoint `0.179129` |
| `ComponentSpacingValues` | `GlimmerSpacing` | 6, 8, 12, 16, 20 |
| `IconSizes` | `GlimmerIconSizes` | 32, 40, 48 |
| `Shapes` | `GlimmerShapes` | 12 small, 36 medium, stadium |
| `Typography` | `GlimmerTypography` | 30/24/20 sizes, weight axes 725, 520, 650 |
| `DepthEffectLevels` | `GlimmerDepth` | five levels, two black layers each, no offset |
| `Surface` timing | `GlimmerMotion` | 800 in, 500 out, 300 minimum press, 16% overlay, 1.5 and 2 borders |
| `Surface` ambient | `GlimmerMotion.ambientEnvelope` | 2 s cycle, 1.8 s delay, 4 s repeat, 0 → 0.2835 → 0.375 → 1 |
| `Surface` border shader | `GlimmerEdge` | four corner colours, smoothstep bands at 0.1, 0.25, 0.4, quarter-turn focus rotation |
| `Surface` blur | `GlimmerEdgeBlur` | 2 → 8 idle, 1 → 3 focused, 5.3 → 15.9 ambient |
| `Surface` tones | `GlimmerTone` | surface at 20, focused at 34, focused border at 85, 69, 77 |
| `Button` | `GlimmerButton` | 48 and 72 minimum heights, medium and large padding |
| `Card` | `GlimmerCard` | 80 minimum height, `medium` padding, 3 between title and supporting text |
| `ListItem` | `GlimmerListItem` | `large` padding all round |
| `TitleChip` | `GlimmerTitleChip` | 44 minimum height, 352 maximum width, `extraSmall` padding, `medium` associated spacing |
| `IconButton` | `GlimmerIconButton` | 48 minimum size, `small` padding |
| `GlimmerHorizontalPager` | `GlimmerPager` | 0.9 minimum scale, 0.69 scale threshold, 0.82 blur threshold, 2 blur, bottom transform origin, 50 edge scrim with its 0.05/0.35/0.65/0.95 envelope |
| `PageIndicator` | `GlimmerPageIndicator` | 6 radius, 27 centre to centre, 18 selected bar, 7 maximum, 8/12 edge fraction, 0.3 unselected alpha |
| `Stack` | `GlimmerStack` | 18 reveal, 0.94 next-item scale, recede to 0.5, two items behind, snap spring |
| `Scrim` | `GlimmerScrim` | erases with `dstOut` over 48, rather than painting the background colour |
| `VoiceInputIndicator` | `GlimmerVoiceInputIndicator` | 32 container, 6 dot, 5x middle bar, 4.2 side offset, 3 spacing |

## Changed on purpose

| What | Upstream | Here | Why |
|---|---|---|---|
| Type, radii, icon sizes | glasses sizes | two thirds | The published sizes come from the 0.6 degree legibility floor of a lens centimetres from the eye. `GlimmerScale.glasses` opts out. |
| Minimum touch heights | 48, 72, 44, 80 | unchanged, except list items at 64 | These are touch targets, not visual measurements, so they do not follow the two-thirds rule. An 80 row is unusually tall for a phone list. |
| Depth | two black shadows drawn around the component | nothing drawn around it; the plane behind withdraws instead, by a ratio taken from the published spreads | Black is transparent on the glasses, so those shadows are a hole rather than a halo. Painted on an opaque screen they are a dark halo, which is Material's language, and on a light ground a bruise. |
| Surface tint strength | opaque | 0.72 dark, 0.66 light | An opaque fill over a backdrop reads as a slab. Applies to the surface role only; a caller-supplied fill keeps full strength. |
| Border shader | AGSL runtime shader, Android 13+ | sampled `SweepGradient` | Runs on every platform Flutter does. Same maths, including the square-normalised angle so the corners land on the component's real corners. |
| Progressive border blur | per-pixel in the shader | two strokes, soft under sharp | A single stroke cannot vary its blur along its own length. |
| `withTone` | HCT, with a CAM16 gamut solve | CIELAB L\*, keeping a\* and b\* | Tone is defined as L\* and `HctUtils` uses the same Epsilon and Kappa. The gamut solve is not reproduced; colours pushed out of sRGB are clamped per channel instead. The shifts Glimmer actually performs are small enough that the two agree. |
| Overscroll | not applicable | a lit edge, never a stretch or a bounce | The stretch renders scrolling content into an offscreen layer, which leaves a surface with no backdrop to read and flattens every glass panel on screen. A stretch is also Material's gesture and a bounce is Cupertino's. |
| Focus | roving, follows the wearer | driven by selection and keyboard focus | A phone has no gaze or touchpad. |

## Deliberately not translated

- **`IndirectPointerGesture`.** Touchpad input on the glasses. There is no
  equivalent on a phone.
- **The ambient border shader itself.** Kept as timing and a brightening rather
  than a per-pixel progressive blur, and off by default.
- **Google Sans Flex.** Glimmer's typeface, and a variable font. This package
  ships no assets, so `fontFamily` is a parameter.

## Depth is transparency

Glimmer's depth levels are black shadows, and on an additive display black is
rendered as nothing at all. So a Glimmer shadow does not darken what is under
it, it *removes* it: the surface behind stops being drawn where the surface in
front approaches, and the world shows through the gap.

That is why an item behind the top of a stack recedes rather than darkening, and
why `GlimmerScrim` takes the content's own alpha down instead of painting the
background colour over it. Opacity and a black overlay look equivalent on a flat
page and are visibly wrong over a backdrop.

The recede has to come from inside the surface. Any layer wrapped around glass
takes away the backdrop it reads: an opacity, a colour filter or a shader mask
leaves the card flat for the whole animation, snaps it back at the end, and
shows its own bounds as a rectangle across the page. `GlimmerEntrance` carries
the progress down instead, and each surface scales its own tint, blur and edge
by it.

Nothing is painted around a surface to say how high it sits. A `GlimmerDepthLevel`
is a number saying how far the plane behind withdraws, and it is spent by whatever
owns both planes: `GlimmerStack` for a stack, `GlimmerModalScrim` for a modal,
where the app is blurred and taken back toward the ground colour rather than
washed with black. On a phone the app behind a card is opaque, so withdrawing
means falling back to whatever the screen is made of, which is also why it works
in a light theme where a black wash is a bruise.

One consequence is easy to miss: with the shadows gone, a surface no longer
absorbs touches as a side effect of the painter behind it, so it absorbs them
deliberately. Without that, a tap on the blank part of a dialog falls through to
the scrim and dismisses it.

## Added for mobile

Glimmer has none of these, because a glasses app shows one thing at a time and
is dismissed with the back gesture. Each is derived from the tokens rather than
borrowed from Material: a dialog withdraws the app behind it by depth level 4
and a sheet by level 3, the same levels the panels would have sat at.

`showGlimmerDialog` · `showGlimmerBottomSheet` · `showGlimmerSnackbar` ·
`showGlimmerMenu` · `GlimmerScaffold` · `GlimmerTopBar` · `GlimmerTextField` ·
`GlimmerSwitch` · `GlimmerSlider` · `GlimmerProgressBar` · `GlimmerBackdrop` ·
`GlimmerScrollBehavior` · `GlimmerOverscrollIndicator` · `MaterialGlimmerApp` ·
`GlimmerEntrance`

## Not translated yet

- **`GlimmerLazyColumn`'s scroll behaviours.** Snapping, the scroll indicator
  and beyond-bounds item retention. `GlimmerList` is a plain `ListView` with the
  right spacing and an integrated title chip.
- **`Scrim` as an edge effect tied to scroll position.** `GlimmerScrim` is a
  static gradient; upstream fades proportionally to how far a list has scrolled.
