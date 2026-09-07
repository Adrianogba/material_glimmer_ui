# Changelog

This project follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/).

## 1.0.0

First release.

### Added

- `MaterialGlimmerApp` and `MaterialGlimmerApp.router`, the application widget,
  alongside `MaterialApp` and `CupertinoApp`.
- `GlimmerTheme.dark()` and `GlimmerTheme.light()`, each a complete `ThemeData`
  with every token in a `ThemeExtension` and the `ColorScheme` and `TextTheme`
  derived from it. `MaterialGlimmerApp` builds both always, so
  `themeMode: ThemeMode.system` works with no other change.
- `GlimmerSurface`, the glass pane everything else is built from. It blurs and
  tints what is painted behind it, lights its edge on focus, and takes a flat
  press overlay rather than a ripple.
- `GlimmerEdge` and `GlimmerEdgeBlur`, the four-corner angular border gradient
  and its progressive blur, as a sampled sweep gradient so it works on every
  platform Flutter runs on.
- `GlimmerBackdrop`, what surfaces are glass over, wired into `GlimmerScaffold`
  through its `backdrop` slot. A theme-coloured gradient by default; takes an
  image, your own colours, or any widget including live content.
- `GlimmerDepth`, five levels expressed as how far the plane behind withdraws
  rather than as a shadow in front. Nothing is drawn around a surface. The level
  is spent by whatever owns both planes: `GlimmerStack` for a stack,
  `GlimmerModalScrim` for a modal, where the app behind is blurred and taken
  back toward the ground colour rather than washed with black, so it reads
  correctly on a light theme too.
- `GlimmerEntrance`, how a glass surface arrives. Glass cannot be faded: an
  opacity layer takes away the backdrop it reads for the whole animation and
  hands it back in one frame at the end. Every surface below scales its own
  tint, blur and edge instead.
- `GlimmerOverscrollIndicator`, installed by `GlimmerScrollBehavior`. Neither a
  stretch nor a bounce: the content does not move, and the edge it ran into
  opens from the middle outward with the bloom brightest where the push lands.
  Moving the content would render the scrollable into an offscreen layer, and
  every glass surface inside it would lose its backdrop.
- `GlimmerRefreshIndicator`, pull to refresh without moving anything. The same
  edge light brightens with the pull, then holds and breathes on the ambient
  envelope while the work runs, instead of sliding a spinner over the list or
  opening a gap above it.
- `GlimmerPageRoute`, a page that arrives instead of sliding. A slide or a fade
  puts the incoming page in its own layer, which takes the backdrop away from
  every glass surface on it for the length of the transition. This one moves
  nothing: the page comes in through `GlimmerEntrance` and the one behind it
  withdraws by its depth level. `GlimmerScaffold` fades its own ground with the
  entrance so a page does not cut its background in on the first frame.
- `GlimmerTone`, the perceptual lightness maths the colours are stated in, so a
  re-skinned palette derives its focused fill and border correctly.
- `GlimmerScale`, choosing between the phone measurements and a set half again
  as large for a display held closer to the eye.
- Tokens: `GlimmerColors`, `GlimmerTypography`, `GlimmerShapes`,
  `GlimmerSpacing`, `GlimmerIconSizes`, `GlimmerDepth` and `GlimmerMotion`.
- Components: `GlimmerCard`, `GlimmerButton`, `GlimmerToggleButton`,
  `GlimmerButtonGroup`, `GlimmerIconButton`, `GlimmerIconToggleButton`,
  `GlimmerText`, `GlimmerIcon`, `GlimmerTitleChip`, `GlimmerList`,
  `GlimmerListItem`, `GlimmerStack`, `GlimmerScrim`,
  `GlimmerVoiceInputIndicator`, `GlimmerPager` and `GlimmerPageIndicator`.
- Overlays: `showGlimmerDialog`, `showGlimmerBottomSheet`,
  `showGlimmerSnackbar` and `showGlimmerMenu`, over a `GlimmerModalScrim`.
- `GlimmerTooltip`, a glass pill rather than a grey slab, kept clear of the
  status bar and the screen edges. `GlimmerIconButton` uses it for `tooltip`.
- `GlimmerProgressBar`, drawn rather than borrowed. The determinate bar is the
  slider's lit track with a glow at the leading end; the indeterminate one
  sends a tapered highlight along the track instead of sliding a block.
- Selection controls, none of which ripple. `GlimmerCheckbox` traces its tick
  on rather than fading it in, `GlimmerRadio` springs its dot out of the centre
  with a halo under it, and `GlimmerTabs` slides a lit marker between choices
  while the labels stay put. It is a segmented control and a tab bar at once.
- `GlimmerCircularProgress`, a ring of light. Determinate brightens toward the
  leading end of the arc; indeterminate travels a tapered arc round the ring.
- `GlimmerSearchField`, `GlimmerTextField` with the parts a search box always
  needs. `GlimmerTextField` gained `suffix`, `autofocus` and `textInputAction`.
- `GlimmerExpansionTile`, a row that opens by growing rather than by fading, so
  glass in the body keeps its backdrop the whole way down.
- `GlimmerDivider`, graded light rather than a flat rule. `GlimmerBadge` and
  `GlimmerAvatar`, both carrying the same lit edge.
- Input and structure: `GlimmerTextField`, `GlimmerSwitch`, `GlimmerSlider`,
  `GlimmerScaffold` and `GlimmerTopBar`.
- Additive surfaces, composited with `BlendMode.plus`, so a surface on dark adds
  light rather than blocking it. Turn it off with `additive: false`.
- No assets and no dependencies beyond Flutter.
