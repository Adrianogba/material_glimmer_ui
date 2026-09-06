# Changelog

This project follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/).

## 1.0.0

First release.

### Added

- `MaterialGlimmerApp` and `MaterialGlimmerApp.router`, the application widget, alongside
  `MaterialApp` and `CupertinoApp`.
- `GlimmerTheme.light()`, a light ground for a system Glimmer does not have,
  and `themeMode` on `MaterialGlimmerApp` so both are always built.
- `GlimmerBackdrop`, what surfaces are glass over, wired into
  `GlimmerScaffold` through its `backdrop` slot.
- `GlimmerPager` and `GlimmerPageIndicator`, with the published scale, blur and
  fade falloffs, the edge scrim and the stretching dot indicator. A page at rest
  is placed with no layer at all, so glass inside it keeps its backdrop.
- `GlimmerScrollBehavior`, installed by `MaterialGlimmerApp`. Android's overscroll
  stretch renders the scrolling content into an offscreen layer, which leaves a
  surface reading its backdrop with nothing to read, so every glass panel went
  flat for the length of the stretch.
- `GlimmerEntrance`, how a glass surface arrives. Glass cannot be faded: an
  opacity layer takes away the backdrop it reads for the whole animation and
  hands it back in one frame at the end. Every surface below scales its own
  tint, blur and edge instead, so a menu or a dialog comes in without the jump.
- `GlimmerEdge` and `GlimmerEdgeBlur`, the four-corner angular border gradient
  and its progressive blur, reimplemented from the published AGSL shader as a
  sweep gradient so it works on every platform rather than Android 13 and up.
- `GlimmerTone`, the perceptual lightness maths Glimmer states its surface and
  border colours in, so a re-skinned palette derives them correctly.
- `GlimmerTheme.dark()`, returning a complete `ThemeData` with every Glimmer
  token in a `ThemeExtension` and with the `ColorScheme` and `TextTheme` derived
  from them.
- Tokens: `GlimmerColors`, `GlimmerTypography`, `GlimmerShapes`,
  `GlimmerSpacing`, `GlimmerIconSizes`, `GlimmerDepth` and `GlimmerMotion`.
- `GlimmerDepth` as a withdrawal rather than a shadow. Glimmer's five levels are
  black shadows, which is depth on a display where black is transparent: the
  shadow is a hole, not a halo. Painted on an opaque phone screen they are a
  dark halo, which is Material's language, so nothing is drawn around a surface
  here. A level says how far the plane behind it withdraws, spaced by the
  published spreads, and it is spent by whatever owns both planes.
- `GlimmerScale`, choosing between the reduced mobile measurements and the
  published glasses numbers.
- Components: `GlimmerSurface`, `GlimmerCard`, `GlimmerButton`,
  `GlimmerToggleButton`, `GlimmerButtonGroup`, `GlimmerIconButton`,
  `GlimmerIconToggleButton`, `GlimmerText`, `GlimmerIcon`, `GlimmerTitleChip`,
  `GlimmerList`, `GlimmerListItem`, `GlimmerStack`, `GlimmerScrim` and
  `GlimmerVoiceInputIndicator`.
- `GlimmerOverscrollIndicator`, installed by `GlimmerScrollBehavior`. Neither
  Material's stretch nor Cupertino's bounce: the content does not move, and the
  edge it ran into opens from the middle outward with the bloom brightest where
  the push lands.
- `GlimmerSlider`, shaped after the media scrubber Glimmer shows rather than
  after Material's slider, with the surface states on the thumb and no ripple.
- Overlays, none of which exist in Glimmer: `showGlimmerDialog`,
  `showGlimmerBottomSheet`, `showGlimmerSnackbar` and `showGlimmerMenu`, over a
  `GlimmerModalScrim` that blurs the app behind and withdraws it toward the
  ground colour by the modal's depth level.
- Other mobile additions that do not exist in Glimmer: `GlimmerTextField`,
  `GlimmerSwitch`, `GlimmerProgressBar`, `GlimmerScaffold` and `GlimmerTopBar`.
- Additive surfaces, composited with `BlendMode.plus` to reproduce the way a
  lens display adds light instead of blocking it.
- No assets and no dependencies beyond Flutter.
