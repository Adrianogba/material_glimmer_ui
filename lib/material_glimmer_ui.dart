/// A Flutter UI kit of glass surfaces and lit edges.
///
/// Inspired by Jetpack Compose Glimmer and Material Design.
///
/// An app widget, a theme, a full token set and a widget library, picked the
/// same way you pick Material or Cupertino. Everything is drawn rather than
/// shipped as assets, and the only dependency is Flutter.
///
/// Surfaces are glass: each one blurs and tints whatever is painted behind it
/// rather than covering it. Focus is a lit edge that grows, brightens and turns
/// toward the focal colour over 800 ms. Depth is the plane behind withdrawing
/// rather than a shadow in front. There are no ripples anywhere.
///
/// [GlimmerTheme] returns a real [ThemeData] with every token in a
/// [ThemeExtension] and the [ColorScheme] and [TextTheme] derived from it, so a
/// Material widget dropped next to one of these inherits the same palette and
/// type instead of clashing with it. Adopt the whole system, or move one screen
/// at a time by passing [GlimmerTheme.dark] to an existing [MaterialApp].
///
/// The tokens ship at phone sizes. Pass [GlimmerScale.glasses] for the larger
/// set, meant for a display held much closer to the eye.
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
export 'src/glimmer_tooltip.dart';
export 'src/glimmer_typography.dart';
export 'src/glimmer_voice_input_indicator.dart';
export 'src/material_glimmer_app.dart';
