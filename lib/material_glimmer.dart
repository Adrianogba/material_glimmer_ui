/// An adaptation of Glimmer, Google's new design language, mixed with Material
/// Design Expressive.
///
/// A design system for Flutter apps: a theme, a full token set and a widget
/// library, picked the same way you pick Material or Cupertino. Everything is
/// drawn rather than shipped as assets, and the only dependency is Flutter.
///
/// The look comes from Glimmer, the design language Google built for its
/// display glasses. Surfaces add light instead of blocking it, focus is an
/// outline that grows and brightens over 800 ms rather than a ripple, depth is
/// a real shadow rather than a tonal overlay, and the palette is a small set of
/// luminous accents on true black.
///
/// The bones come from Material Design Expressive: phone-sized touch targets,
/// generous rounded shapes, and the [ThemeData], [ColorScheme] and [TextTheme]
/// plumbing every Flutter app already speaks.
///
/// Colours, spacing, motion timing and the depth levels are the published
/// values. Type, corner radii, icon sizes and shadow geometry are scaled to two
/// thirds, because Glimmer's sizes are set by the legibility floor of a lens a
/// few centimetres from the eye and a phone at arm's length does not need them.
/// Pass [GlimmerScale.glasses] to opt out and get the published numbers.
///
/// Everything spatial is left behind. Nothing here depends on gaze, head pose
/// or a touchpad.
///
/// ```dart
/// GlimmerApp(
///   title: 'Bakery',
///   home: GlimmerScaffold(
///     title: 'Bakery',
///     body: GlimmerList(
///       title: 'Grocery list',
///       children: const [
///         GlimmerListItem(label: 'Milk'),
///         GlimmerListItem(label: 'Bread'),
///       ],
///     ),
///   ),
/// )
/// ```
library;

export 'src/glimmer_app.dart';
export 'src/glimmer_backdrop.dart';
export 'src/glimmer_button.dart';
export 'src/glimmer_card.dart';
export 'src/glimmer_colors.dart';
export 'src/glimmer_controls.dart';
export 'src/glimmer_depth.dart';
export 'src/glimmer_edge.dart';
export 'src/glimmer_icon_button.dart';
export 'src/glimmer_list.dart';
export 'src/glimmer_metrics.dart';
export 'src/glimmer_motion.dart';
export 'src/glimmer_pager.dart';
export 'src/glimmer_scroll.dart';
export 'src/glimmer_shell.dart';
export 'src/glimmer_surface.dart';
export 'src/glimmer_text.dart';
export 'src/glimmer_theme.dart';
export 'src/glimmer_title_chip.dart';
export 'src/glimmer_tone.dart';
export 'src/glimmer_typography.dart';
export 'src/glimmer_voice_input_indicator.dart';
