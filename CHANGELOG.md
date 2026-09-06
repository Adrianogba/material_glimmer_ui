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
- Input and structure: `GlimmerTextField`, `GlimmerSwitch`, `GlimmerSlider`,
  `GlimmerProgressBar`, `GlimmerScaffold` and `GlimmerTopBar`.
- Additive surfaces, composited with `BlendMode.plus`, so a surface on dark adds
  light rather than blocking it. Turn it off with `additive: false`.
- No assets and no dependencies beyond Flutter.
