<h1 align="center">Material Glimmer UI</h1>

<p align="center">
  A Flutter UI kit of glass surfaces and lit edges.<br>
  Inspired by Jetpack Compose Glimmer and Material Design.
</p>

<p align="center">
  <a href="https://pub.dev/packages/material_glimmer_ui"><img src="https://img.shields.io/pub/v/material_glimmer_ui.svg" alt="pub"></a>
  <a href="https://pub.dev/packages/material_glimmer_ui"><img src="https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-1575F9" alt="platforms"></a>
  <a href="https://github.com/Adrianogba/material_glimmer_ui/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="license"></a>
</p>

## What it is

A UI kit for Flutter apps: an app widget, a theme, a full token set and a widget
library, picked the same way you pick Material or Cupertino. Everything is
drawn, not shipped as assets, and the only dependency is Flutter itself.

Surfaces are glass. Each one blurs and tints whatever is painted behind it
rather than covering it, so the colour and movement underneath still come
through. Focus is a lit edge: an outline that grows, brightens and turns toward
the focal colour over 800 ms. Depth is not a shadow, it is the plane behind
withdrawing. There are no ripples anywhere.

It is a full design system rather than a set of widgets to sprinkle on top of
one. `GlimmerTheme` returns a real `ThemeData` with every token in a
`ThemeExtension` and the `ColorScheme` and `TextTheme` derived from it, so a
Material widget dropped next to one of these inherits the same palette and type
instead of clashing with it.

## Install

```sh
flutter pub add material_glimmer_ui
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:material_glimmer_ui/material_glimmer_ui.dart';

MaterialGlimmerApp(
  title: 'Bakery',
  home: GlimmerScaffold(
    title: 'Bakery',
    backdrop: const GlimmerBackdrop(),
    body: GlimmerList(
      title: 'Grocery list',
      children: const [
        GlimmerListItem(label: 'Milk', leadingIcon: Icons.circle_outlined),
        GlimmerListItem(label: 'Bread', leadingIcon: Icons.circle_outlined),
      ],
    ),
  ),
);
```

`MaterialGlimmerApp` sits where `MaterialApp` and `CupertinoApp` sit, and there
is a `MaterialGlimmerApp.router` for `go_router` users. Under the hood it is a
`MaterialApp` carrying the Glimmer themes, and that is deliberate: Flutter's
routing, localisation and text selection live there, and reimplementing them
would buy nothing but bugs. What this kit replaces is the look and the
interaction model, and both come from the theme.

So you can adopt the whole system, or move one screen at a time by passing
`GlimmerTheme.dark()` to your existing `MaterialApp`.

## Backdrops

A surface has to have something to be glass over. `GlimmerBackdrop` is what the
kit paints behind everything else:

```dart
GlimmerScaffold(
  backdrop: const GlimmerBackdrop(),
  body: ...,
)
```

The default is a slow gradient built from the theme's own focal colours. Pass
`image` for a photo, `colors` for your own gradient, or `child` for anything
else, including live content such as a camera preview or a map. Over a flat fill
the surfaces still work, they are simply doing less.

## The edge

The border is the part worth knowing about. It is not a stroke of one colour: it
is an angular gradient with a different colour at each corner, symmetric about
whichever corner the light falls on, and the whole gradient rotates a quarter
turn as a surface takes focus. On top of that it is blurred progressively, crisp
where the light lands and soft on the far side, sharpening as focus arrives.

`GlimmerEdge` builds it as a sampled sweep gradient, so it works on every
platform Flutter runs on. Two details are easy to get wrong and are handled:
each axis is normalised before the angle is taken, so the gradient's corners are
the component's real corners at any aspect ratio, and the stroke is an inner
border with its outer edge on the component's boundary.

`GlimmerTone` carries the perceptual lightness maths the colours are stated in,
so a re-skinned palette derives its focused fill and focused border correctly
rather than only the default looking right.

## Depth

Five levels, and none of them draws anything. A `GlimmerDepthLevel` says how far
the plane *behind* withdraws, and it is spent by whatever owns both planes:
`GlimmerStack` for the items behind the top of a stack, `GlimmerModalScrim` for
the app behind a modal, which is blurred and taken back toward the ground colour
rather than washed with black. That is why it reads correctly on a light theme,
where a black wash is a bruise.

## Light and dark

`GlimmerTheme.dark()` is a small set of luminous accents on true black.
`GlimmerTheme.light()` is the same system with the hues taken to the lightness
they need on a light ground, where surfaces filter the backdrop instead of
adding to it. Timing, spacing, depth and the graded edge are identical in both.

`MaterialGlimmerApp` builds both always, so `themeMode: ThemeMode.system` works
with no other change.

## Additive surfaces

On dark, a surface paints its fill with `BlendMode.plus`, adding light rather
than blocking it. Over a flat dark background that is indistinguishable from an
ordinary fill; over a photo or a gradient it becomes luminous glass.

Turn it off with `additive: false` on a surface that has to be opaque.

## Scrolling

Material stretches a list at its end and Cupertino bounces it. Both move the
content, and this kit cannot afford to: a stretch renders the scrollable into an
offscreen layer, and every glass surface inside it loses the backdrop it was
reading.

So the content does not move. `GlimmerOverscrollIndicator` lights up the edge
the list ran into, with the same graded light the surfaces use: a line that
opens from the middle outward and a bloom brightest where the push lands, both
following how hard the list is pushed and falling away on the spring everything
else settles with.

`MaterialGlimmerApp` installs it through `GlimmerScrollBehavior`. Pass your own
`scrollBehavior` to opt out.

`GlimmerRefreshIndicator` is the same light doing more work. Pull past the top
and the edge brightens with the pull; let go past the trigger and it holds and
breathes on the ambient envelope until the refresh finishes. No spinner slides
over the list and no gap opens above it.

## Screens

`GlimmerPageRoute` pushes a page without moving it. `MaterialPageRoute` slides
the incoming page and `CupertinoPageRoute` pushes it in from the side; both put
it in a layer of its own on the way, which takes the backdrop away from every
glass surface on it, so a pushed screen goes flat for the whole transition and
snaps back at the end.

Here the arriving page comes in through `GlimmerEntrance`: its ground fades up
and its surfaces build their own tint, blur and edge as they land. The page
being covered withdraws by its depth level rather than sliding away, the same
thing a modal does to the app behind it.

```dart
Navigator.of(context).push(
  GlimmerPageRoute(builder: (context) => const DetailScreen()),
);
```

## Components

**App and structure.**
`MaterialGlimmerApp` · `MaterialGlimmerApp.router` · `GlimmerScaffold` ·
`GlimmerTopBar` · `GlimmerNavigationItem` · `GlimmerBackdrop`

**Surfaces.**
`GlimmerSurface` · `GlimmerCard`

**Actions.**
`GlimmerButton` · `GlimmerToggleButton` · `GlimmerButtonGroup` ·
`GlimmerIconButton` · `GlimmerIconToggleButton`

**Content.**
`GlimmerText` · `GlimmerIcon` · `GlimmerTitleChip` · `GlimmerTooltip` ·
`GlimmerDivider` · `GlimmerBadge` · `GlimmerAvatar` ·
`GlimmerVoiceInputIndicator`

**Collections.**
`GlimmerList` · `GlimmerListItem` · `GlimmerExpansionTile` · `GlimmerStack` ·
`GlimmerPager` · `GlimmerPageIndicator` · `GlimmerScrim` ·
`GlimmerRefreshIndicator`

**Input.**
`GlimmerTextField` · `GlimmerSearchField` · `GlimmerSwitch` ·
`GlimmerCheckbox` · `GlimmerRadio` · `GlimmerTabs` · `GlimmerSlider` ·
`GlimmerProgressBar` · `GlimmerCircularProgress`

**Overlays.**
`showGlimmerDialog` · `showGlimmerBottomSheet` · `showGlimmerSnackbar` ·
`showGlimmerMenu` · `GlimmerDialog` · `GlimmerBottomSheet` ·
`GlimmerSnackbar` · `GlimmerMenu` · `GlimmerModalScrim`

**Tokens and machinery.**
`GlimmerTheme` · `GlimmerTokens` · `GlimmerColors` · `GlimmerTypography` ·
`GlimmerShapes` · `GlimmerSpacing` · `GlimmerIconSizes` · `GlimmerDepth` ·
`GlimmerMotion` · `GlimmerEdge` · `GlimmerEdgeBlur` · `GlimmerTone` ·
`GlimmerEntrance` · `GlimmerScrollBehavior` · `GlimmerOverscrollIndicator` ·
`GlimmerPageRoute` · `GlimmerScale`

## Two scales

The tokens ship at phone sizes. `GlimmerScale.glasses` switches type, corner
radii and icon sizes to a set half again as large, for a display held much
closer to the eye than a phone:

```dart
MaterialGlimmerApp(scale: GlimmerScale.glasses, home: ...)
```

Minimum touch heights do not change with it. A medium button is 48, a large one
72, an icon button 48. Those are touch targets, not visual measurements.

## Notes

- **Focus is yours to drive.** Each surface takes a `focused` flag, so selection
  belongs to your app. Keyboard focus is picked up on its own and gets the same
  treatment.
- **Glass cannot be faded.** An `Opacity` or a `FadeTransition` around a surface
  puts it in its own layer, which takes away the backdrop it reads.
  `GlimmerEntrance` carries an arrival progress down the tree instead and each
  surface scales its own tint, blur and edge by it. Use it if you build a
  surface that has to appear.
- **No assets.** Type is whatever `fontFamily` you pass, or the platform
  default.

## License

MIT. See [LICENSE](https://github.com/Adrianogba/material_glimmer_ui/blob/main/LICENSE).

Independent package, not affiliated with Google. Jetpack Compose Glimmer and
Material Design are Google's, under Apache 2.0. No code from either was copied.
