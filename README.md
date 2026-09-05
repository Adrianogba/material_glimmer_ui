<h1 align="center">Material Glimmer UI</h1>

<p align="center">
  A UI kit adapting Glimmer, Google's new design language,<br>
  mixed with Material Design Expressive.
</p>

<p align="center">
  <a href="https://pub.dev/packages/material_glimmer_ui"><img src="https://img.shields.io/pub/v/material_glimmer_ui.svg" alt="pub"></a>
  <a href="https://pub.dev/packages/material_glimmer_ui"><img src="https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-1575F9" alt="platforms"></a>
  <a href="https://github.com/Adrianogba/material_glimmer_ui/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-green.svg" alt="license"></a>
</p>

## What it is

A UI kit for Flutter apps: a theme, a full token set and a widget library,
picked the same way you pick Material or Cupertino. Everything is drawn, not
shipped as assets, and the only dependency is Flutter itself.

The look comes from **Glimmer**, the design language Google built for its
display glasses. Surfaces add light instead of blocking it. Focus is an outline
that grows and brightens over 800 ms, not a ripple. Depth is a real shadow, not
a tonal overlay. The palette is a small set of luminous accents on true black.

The bones come from **Material Design Expressive**: phone-sized touch targets,
generous rounded shapes, a scaffold with a bar and a navigation strip, and the
`ThemeData`, `ColorScheme` and `TextTheme` plumbing every Flutter app already
speaks. So a Material widget dropped next to a Glimmer one inherits the same
palette and type instead of clashing with it.

What is left behind is everything spatial. Nothing here depends on gaze, head
pose or a touchpad, and none of it needs an XR device.

## Install

```sh
flutter pub add material_glimmer_ui
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:material_glimmer_ui/material_glimmer_ui.dart';

GlimmerApp(
  title: 'Bakery',
  home: GlimmerScaffold(
    title: 'Bakery',
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

`GlimmerApp` sits where `MaterialApp` and `CupertinoApp` sit, and there is a
`GlimmerApp.router` for `go_router` users. Under the hood it is a `MaterialApp`
carrying `GlimmerTheme.dark()`, and that is deliberate: Flutter's routing,
localisation, scroll behaviour and text selection live there, and reimplementing
them would buy nothing but bugs. What Glimmer replaces is the look and the
interaction model, and both come from the theme.

Because it is a real `ThemeData`, the Glimmer tokens are mapped onto the
`ColorScheme` and the `TextTheme`. A Material widget placed next to a Glimmer
one inherits the same palette and type rather than clashing with it. Adopt the
whole system, or move one screen at a time by passing `GlimmerTheme.dark()` to
your existing `MaterialApp`.

## Fidelity

Every value is labelled for what it is. Nothing is approximated without saying
so.

| Token | Upstream | Here |
|---|---|---|
| Colours | `primary` `#9BBFFF`, `secondary` `#4C88E9`, `positive` `#63FEA8`, `negative` `#FFA7A0`, `surface` `#303030`, `outline` `#606460` | identical |
| Spacing | 6, 8, 12, 16, 20 | identical |
| Focus timing | 800 ms in, 500 ms out, `LinearOutSlowInEasing` | identical |
| Pressed | white overlay at 16%, 300 ms minimum, springs at stiffness 8000 and 50 | identical |
| Ambient sweep | 2 s cycle, 1.8 s initial delay, 4 s repeat, envelope 0 to 0.2835 to 0.375 to 1 | identical, opt-in |
| Border | 1.5 resting, 2 focused | identical |
| Border gradient | four corner colours, angular, symmetric about the lit corner, rotating a quarter turn on focus | identical, as a sweep gradient rather than an AGSL shader |
| Border blur | 2 to 8 resting, 1 to 3 focused, 5.3 to 15.9 at the ambient peak | identical radii, two passes instead of a per-pixel shader |
| Tones | surface at 20, focused surface at 34, focused border at 85, 69 and 77 | identical, derived rather than hard-coded |
| Depth | 5 levels, 2 black shadow layers each, no offset | radii and spreads at two thirds |
| Typography | 30/24/20 sp for title and body, 18 for caption, weight axes 725/520/650 | sizes at two thirds, line-height ratios and weights identical |
| Shapes | 12 small, 36 standard, stadium | 8 and 24, stadium |
| Icons | 32, 40, 48 | 21.3, 26.7, 32 |

Two thirds is not a guess. Glimmer's sizes come from the 0.6 degree legibility
floor of a lens sitting centimetres from the eye. A phone at arm's length does
not need them, and at full size a Glimmer card does not fit the screen. For the
published numbers, pass `GlimmerScale.glasses`:

```dart
GlimmerApp(scale: GlimmerScale.glasses, home: ...)
```

Minimum touch heights do not follow that rule. A medium button is still 48, a
large one 72, an icon button 48. Those are touch targets, not visual
measurements.

Every value in the table is pinned by a test, so if upstream moves, the build
says so. [TRANSLATION.md](TRANSLATION.md) is the file-by-file comparison: what
was taken verbatim, what was changed and why, and what has not been translated
yet.

### The border is the whole thing

Glimmer's border is not a stroke of one colour. It is an angular gradient with a
different colour at each corner, symmetric about whichever corner the light
falls on, and the entire gradient rotates a quarter turn as a surface takes
focus. On top of that it is blurred progressively: crisp where the light lands,
soft on the far side, sharpening as focus arrives. That is what the design
language is named after, and a flat outline gets none of it.

Upstream it is an AGSL runtime shader, so it needs Android 13 and runs on
Android only. `GlimmerEdge` reimplements the same maths as a sweep gradient, and
it works everywhere Flutter does. Two details matter and are easy to get wrong:
the shader normalises each axis before taking the angle, so its corners are the
component's real corners whatever its proportions, and the border is an inner
one, with its outer edge on the component's boundary.

`GlimmerTone` carries the tone maths the colours are stated in, so a re-skinned
palette derives its focused fill and focused border the way the published one
does instead of only the default looking right.

## Backdrops

On glasses, what sits behind a surface is the room. Black is rendered as fully
transparent, so every surface is glass over whatever the wearer is looking at,
and that is where the whole language gets its character.

A phone has nothing behind the screen. Translating black literally leaves a flat
void, the surfaces have nothing to filter, and the system loses the one thing
that made it interesting. So the app supplies the backdrop and the surfaces
frost it:

```dart
GlimmerScaffold(
  backdrop: const GlimmerBackdrop(),
  body: ...,
)
```

The default is a slow gradient built from the theme's own focal colours. Pass
`image` for a photo, `colors` for your own gradient, or `child` for anything
else, including live content such as a camera preview or a map.

## Light

Glimmer is dark only, and on a lens it has to be: an additive display renders
black as transparent, so a light interface would be a wall of light in front of
the wearer. A phone has no such constraint.

`GlimmerTheme.light()` takes the published hues to the lightness they need on a
light ground, and surfaces filter the backdrop instead of adding to it, which is
the same glass seen from the other side. Timing, spacing, depth levels and the
graded edge are unchanged. `GlimmerApp` builds both themes always, so
`themeMode: ThemeMode.system` works with no other change.

## Additive surfaces

A lens display builds its image by adding light, so a Glimmer surface never
hides what is behind it. `GlimmerSurface` paints its fill with `BlendMode.plus`,
which is the same operation. Over the black Glimmer background that is
indistinguishable from an ordinary fill. Over a photo or a gradient it becomes
the luminous glass the language is named for.

Turn it off with `additive: false` on a surface that has to be opaque.

## Components

| Glimmer | Here |
|---|---|
| (none) | `GlimmerApp`, `GlimmerApp.router`, `GlimmerBackdrop` |
| `Surface` | `GlimmerSurface` |
| `Card` | `GlimmerCard` |
| `Button`, `ToggleButton` | `GlimmerButton`, `GlimmerToggleButton` |
| `ButtonGroup` | `GlimmerButtonGroup` |
| `IconButton`, `IconToggleButton` | `GlimmerIconButton`, `GlimmerIconToggleButton` |
| `Text`, `Icon` | `GlimmerText`, `GlimmerIcon` |
| `TitleChip` | `GlimmerTitleChip` |
| `List`, `ListItem` | `GlimmerList`, `GlimmerListItem` |
| `HorizontalPager` | `GlimmerPager`, `GlimmerPageIndicator` |
| `Stack` | `GlimmerStack` |
| `Scrim` | `GlimmerScrim` |
| `VoiceInputIndicator` | `GlimmerVoiceInputIndicator` |
| `Colors`, `Typography`, `Shapes`, `ComponentSpacingValues`, `IconSizes`, `DepthEffectLevels` | `GlimmerColors`, `GlimmerTypography`, `GlimmerShapes`, `GlimmerSpacing`, `GlimmerIconSizes`, `GlimmerDepth` |
| the border shader | `GlimmerEdge`, `GlimmerEdgeBlur` |
| HCT tone, for deriving colours | `GlimmerTone` |

### Mobile additions

These do not exist in Glimmer and are marked as such in the source. Display
glasses take text by voice, show one thing at a time and are dismissed with the
back gesture, so there is no text field, no switch and no bar across the top. A
phone app needs all three.

`GlimmerTextField` · `GlimmerSwitch` · `GlimmerProgressBar` ·
`GlimmerScaffold` · `GlimmerTopBar` · `GlimmerNavigationItem`

## Scrolling

`GlimmerApp` installs `GlimmerScrollBehavior`. Android's overscroll stretch
scales the scrolling content, and to do that Flutter renders it into an
offscreen layer. A surface that reads what is painted behind it finds nothing
there, so every glass panel on the screen goes flat for as long as the stretch
lasts and snaps back when it ends.

Dropping overscroll feedback would be its own bug, so the behaviour paints a
glow instead. It is drawn over the content rather than by transforming it, so
nothing is isolated. Pass your own `scrollBehavior` to opt out.

## Deliberately left out

- **Roving touchpad focus.** On a phone, selection belongs to your app, so each
  surface's `focused` is yours to drive. Keyboard focus is picked up on its own
  and gets the same treatment.
- **The Android 13+ border shader.** Glimmer's ambient sweep is drawn by a
  runtime shader in the glasses renderer. The timing envelope is the same here.
  The blur is painted as a stroke instead.
- **Google Sans Flex.** It is Glimmer's typeface and a variable one. This
  package ships no assets. Pass `fontFamily` if you have the font in your app.
- **Roving focus that follows a pointer.** Upstream the lit corner tracks where
  the wearer is looking. A phone has no equivalent signal, so the rotation is
  driven by focus arriving rather than by a direction.

## License

MIT. See [LICENSE](https://github.com/Adrianogba/material_glimmer_ui/blob/main/LICENSE).

Jetpack Compose Glimmer belongs to Google, under Apache 2.0. This is an
independent package, not affiliated with Google. No Glimmer code was copied. The
design values were read from the public documentation and the open AndroidX
source, and reimplemented in Dart.
