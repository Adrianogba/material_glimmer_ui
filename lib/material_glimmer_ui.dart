/// A UI kit adapting Glimmer, Google's new design language, mixed with Material
/// Design Expressive.
///
/// A UI kit for Flutter apps: a theme, a full token set and a widget library,
/// picked the same way you pick Material or Cupertino. Everything is drawn
/// rather than shipped as assets, and the only dependency is Flutter.
///
/// The look comes from Glimmer, the design language Google built for its
/// display glasses. Surfaces add light instead of blocking it, focus is an
/// outline that grows and brightens over 800 ms rather than a ripple, depth is
/// the plane behind withdrawing rather than a shadow in front, and the palette
/// is a small set of luminous accents on true black.
///
/// The bones come from Material Design Expressive: phone-sized touch targets,
/// generous rounded shapes, and the [ThemeData], [ColorScheme] and [TextTheme]
/// plumbing every Flutter app already speaks.
///
/// Colours, spacing and motion timing are the published values, and the depth
/// levels keep the published spacing between them. Type, corner radii and icon
/// sizes are scaled to two thirds, because Glimmer's sizes are set by the
/// legibility floor of a lens a few centimetres from the eye and a phone at
/// arm's length does not need them.
/// Pass [GlimmerScale.glasses] to opt out and get the published numbers.
///
/// Everything spatial is left behind. Nothing here depends on gaze, head pose
/// or a touchpad.
///
/// ```dart
/// MaterialGlimmerApp(
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

export 'src/glimmer_backdrop.dart';
export 'src/glimmer_button.dart';
export 'src/glimmer_card.dart';
export 'src/glimmer_colors.dart';
export 'src/glimmer_controls.dart';
export 'src/glimmer_depth.dart';
export 'src/glimmer_edge.dart';
export 'src/glimmer_entrance.dart';
export 'src/glimmer_icon_button.dart';
export 'src/glimmer_list.dart';
export 'src/glimmer_menu.dart';
export 'src/glimmer_metrics.dart';
export 'src/glimmer_modal.dart';
export 'src/glimmer_motion.dart';
export 'src/glimmer_overscroll.dart';
export 'src/glimmer_pager.dart';
export 'src/glimmer_scroll.dart';
export 'src/glimmer_shell.dart';
export 'src/glimmer_slider.dart';
export 'src/glimmer_snackbar.dart';
export 'src/glimmer_surface.dart';
export 'src/glimmer_text.dart';
export 'src/glimmer_theme.dart';
export 'src/glimmer_title_chip.dart';
export 'src/glimmer_tone.dart';
export 'src/glimmer_typography.dart';
export 'src/glimmer_voice_input_indicator.dart';
export 'src/material_glimmer_app.dart';
