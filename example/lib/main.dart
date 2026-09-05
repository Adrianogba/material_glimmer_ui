import 'package:flutter/material.dart';
import 'package:material_glimmer/material_glimmer.dart';

void main() => runApp(const MaterialGlimmerGallery());

/// The gallery app.
class MaterialGlimmerGallery extends StatefulWidget {
  /// Creates the gallery.
  const MaterialGlimmerGallery({super.key});

  @override
  State<MaterialGlimmerGallery> createState() => _MaterialGlimmerGalleryState();
}

class _MaterialGlimmerGalleryState extends State<MaterialGlimmerGallery> {
  var _scale = GlimmerScale.mobile;
  var _mode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return GlimmerApp(
      title: 'Material Glimmer',
      debugShowCheckedModeBanner: false,
      scale: _scale,
      themeMode: _mode,
      home: _GalleryHome(
        scale: _scale,
        onScaleChanged: (scale) => setState(() => _scale = scale),
        mode: _mode,
        onModeChanged: (mode) => setState(() => _mode = mode),
      ),
    );
  }
}

class _GalleryHome extends StatefulWidget {
  const _GalleryHome({
    required this.scale,
    required this.onScaleChanged,
    required this.mode,
    required this.onModeChanged,
  });

  final GlimmerScale scale;
  final ValueChanged<GlimmerScale> onScaleChanged;
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onModeChanged;

  @override
  State<_GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<_GalleryHome> {
  var _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _OverviewPage(),
      const _ComponentsPage(),
      _FoundationsPage(
        scale: widget.scale,
        onScaleChanged: widget.onScaleChanged,
        mode: widget.mode,
        onModeChanged: widget.onModeChanged,
      ),
    ];

    return GlimmerScaffold(
      backdrop: const GlimmerBackdrop(),
      title: 'Material Glimmer',
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlimmerIconButton(
            icon: widget.mode == ThemeMode.dark
                ? Icons.dark_mode_outlined
                : Icons.light_mode_outlined,
            tooltip: widget.mode == ThemeMode.dark
                ? 'Switch to light'
                : 'Switch to dark',
            onPressed: () => widget.onModeChanged(
              widget.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
            ),
          ),
          SizedBox(width: GlimmerTheme.of(context).spacing.small),
          GlimmerIconButton(
            icon: Icons.auto_awesome,
            tooltip: 'About',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => const _AboutSheet(),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _tab, children: pages),
      selectedIndex: _tab,
      onNavigationChanged: (value) => setState(() => _tab = value),
      navigationItems: const [
        GlimmerNavigationItem(label: 'Overview', icon: Icons.explore_outlined),
        GlimmerNavigationItem(
            label: 'Components', icon: Icons.widgets_outlined),
        GlimmerNavigationItem(label: 'Foundations', icon: Icons.tune),
      ],
    );
  }
}

class _OverviewPage extends StatefulWidget {
  const _OverviewPage();

  @override
  State<_OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<_OverviewPage> {
  var _saved = false;
  var _stackIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final type = tokens.typography;
    final spacing = tokens.spacing;

    return ListView(
      padding: EdgeInsets.fromLTRB(spacing.large, 24, spacing.large, 24),
      children: [
        Text('An interface\nwith atmosphere.', style: type.titleLarge),
        SizedBox(height: spacing.medium),
        Text(
          'Surfaces filter what is behind them instead of covering it. Focus '
          'is a lit edge rather than a ripple. Depth is a real shadow rather '
          'than a tonal overlay.',
          style: type.bodySmall.copyWith(color: tokens.colors.outline),
        ),
        SizedBox(height: spacing.extraLarge),

        // Surfaces over something busy, which is where glass is actually
        // visible.
        const _SectionLabel('Glass'),
        SizedBox(height: spacing.medium),
        ClipRRect(
          borderRadius: tokens.shapes.medium,
          child: Stack(
            children: [
              const _Backdrop(),
              Padding(
                padding: EdgeInsets.all(spacing.large),
                child: Column(
                  children: [
                    const GlimmerTitleChip(
                      'Museu do Café',
                      leadingIcon: Icons.place_outlined,
                    ),
                    SizedBox(
                      height: GlimmerTitleChipDefaults.associatedContentSpacing(
                          context),
                    ),
                    const GlimmerCard(
                      title: 'Arrive 10:08',
                      supportingText: 'Six minutes on foot, mostly shade',
                      leadingIcon: Icons.directions_walk,
                    ),
                    SizedBox(height: spacing.medium),
                    // The same card at a far lower tint and a wider blur.
                    // Glimmer's own examples sit closer to this end: the
                    // backdrop is most of what you see, and the surface is
                    // mostly its lit edge.
                    const GlimmerCard(
                      opacity: 0.2,
                      blur: 36,
                      title: 'Santos, 24 degrees',
                      supportingText: 'Clear sun all day',
                      leadingIcon: Icons.wb_sunny_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.extraLarge),

        const _SectionLabel('Card and actions'),
        SizedBox(height: spacing.medium),
        GlimmerCard(
          focused: _saved,
          onTap: () => setState(() => _saved = !_saved),
          title: 'Jabuticaba',
          supportingText: 'Paulista street market, R\$18 a kilo',
          leadingIcon: Icons.local_grocery_store_outlined,
        ),
        SizedBox(height: spacing.medium),
        GlimmerButtonGroup(
          children: [
            GlimmerButton(
              label: _saved ? 'Saved' : 'Save',
              leadingIcon: _saved ? Icons.check : Icons.bookmark_add_outlined,
              prominent: true,
              onPressed: () => setState(() => _saved = !_saved),
            ),
            GlimmerButton(
              label: 'Share',
              leadingIcon: Icons.ios_share,
              onPressed: () {},
            ),
          ],
        ),
        SizedBox(height: spacing.extraLarge),

        const _SectionLabel('Stack'),
        SizedBox(height: spacing.small),
        Text(
          'One item at a time. Swipe up and down.',
          style: type.caption.copyWith(color: tokens.colors.outline),
        ),
        SizedBox(height: spacing.medium),
        GlimmerStack(
          onIndexChanged: (index) => setState(() => _stackIndex = index),
          children: const [
            GlimmerCard(
              title: 'Rafa',
              supportingText: 'Anything from the bakery? I am in the queue.',
              leadingIcon: Icons.chat_bubble_outline,
            ),
            GlimmerCard(
              title: 'Tropicália',
              supportingText: 'Now playing, 3 minutes 23 left',
              leadingIcon: Icons.music_note_outlined,
            ),
            GlimmerCard(
              title: 'Saturday market',
              supportingText: 'Jabuticaba, papaya, kale, pão de queijo',
              leadingIcon: Icons.checklist,
            ),
          ],
        ),
        SizedBox(height: spacing.medium),
        Center(
          child: Text(
            '${_stackIndex + 1} of 3',
            style: type.caption.copyWith(color: tokens.colors.outline),
          ),
        ),
      ],
    );
  }
}

class _ComponentsPage extends StatefulWidget {
  const _ComponentsPage();

  @override
  State<_ComponentsPage> createState() => _ComponentsPageState();
}

class _ComponentsPageState extends State<_ComponentsPage> {
  final _bought = <String>{};
  var _muted = false;
  var _listening = true;
  var _immersive = false;
  var _progress = 0.4;

  static const _pagerPages = <(String, String, IconData)>[
    ('Museu do Café', 'Santos, open until five', Icons.museum_outlined),
    ('Pinacoteca', 'Luz, new exhibition', Icons.palette_outlined),
    ('Mercado Municipal', 'Centro, mortadella sandwich', Icons.storefront),
  ];

  static const _groceries = [
    'Pão de queijo',
    'Jabuticaba',
    'Papaya',
    'Kale',
    'Coffee',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final spacing = tokens.spacing;

    return ListView(
      padding: EdgeInsets.fromLTRB(spacing.large, 24, spacing.large, 24),
      children: [
        const _SectionLabel('List with an integrated title'),
        SizedBox(height: spacing.medium),
        for (final item in _groceries) ...[
          GlimmerListItem(
            label: item,
            leadingIcon: _bought.contains(item)
                ? Icons.check_circle
                : Icons.circle_outlined,
            selected: _bought.contains(item),
            onTap: () => setState(
              () => _bought.contains(item)
                  ? _bought.remove(item)
                  : _bought.add(item),
            ),
          ),
          SizedBox(height: spacing.medium),
        ],
        SizedBox(height: spacing.large),
        const _SectionLabel('Buttons'),
        SizedBox(height: spacing.medium),
        Wrap(
          spacing: spacing.medium,
          runSpacing: spacing.medium,
          children: [
            GlimmerButton(
              label: 'Button',
              leadingIcon: Icons.send_outlined,
              onPressed: () {},
            ),
            GlimmerButton(
                label: 'Prominent', prominent: true, onPressed: () {}),
            const GlimmerButton(label: 'Disabled', onPressed: null),
            GlimmerToggleButton(
              label: _muted ? 'Muted' : 'Mute',
              leadingIcon: _muted ? Icons.volume_off : Icons.volume_up,
              selected: _muted,
              onChanged: (value) => setState(() => _muted = value),
            ),
          ],
        ),
        SizedBox(height: spacing.medium),
        GlimmerButton(
          label: 'Large, for the one action that matters',
          leadingIcon: Icons.navigation_outlined,
          size: GlimmerButtonSize.large,
          expand: true,
          onPressed: () {},
        ),
        SizedBox(height: spacing.extraLarge),
        const _SectionLabel('Pager'),
        SizedBox(height: spacing.small),
        Text(
          'Pages shorten, blur and fade as they leave the centre.',
          style:
              tokens.typography.caption.copyWith(color: tokens.colors.outline),
        ),
        SizedBox(height: spacing.medium),
        SizedBox(
          height: 220,
          child: GlimmerPager(
            itemCount: _pagerPages.length,
            itemBuilder: (context, page) => GlimmerCard(
              title: _pagerPages[page].$1,
              supportingText: _pagerPages[page].$2,
              leadingIcon: _pagerPages[page].$3,
            ),
          ),
        ),
        SizedBox(height: spacing.extraLarge),
        const _SectionLabel('Icon buttons and voice input'),
        SizedBox(height: spacing.medium),
        Row(
          children: [
            GlimmerIconButton(
              icon: Icons.mic_none,
              tooltip: 'Speak',
              prominent: true,
              onPressed: () => setState(() => _listening = !_listening),
            ),
            SizedBox(width: spacing.medium),
            GlimmerIconToggleButton(
              icon: Icons.bookmark_outline,
              selectedIcon: Icons.bookmark,
              selected: _bought.isNotEmpty,
              tooltip: 'Bookmark',
              onChanged: (_) => setState(_bought.clear),
            ),
            SizedBox(width: spacing.extraLarge),
            GlimmerVoiceInputIndicator(listening: _listening),
          ],
        ),
        SizedBox(height: spacing.extraLarge),
        const _SectionLabel('Mobile additions'),
        SizedBox(height: spacing.small),
        Text(
          'Glimmer has no text field, switch or progress bar. Display glasses '
          'take text by voice. These are drawn from the same tokens.',
          style:
              tokens.typography.caption.copyWith(color: tokens.colors.outline),
        ),
        SizedBox(height: spacing.medium),
        const GlimmerTextField(
          label: 'Add an item',
          prefixIcon: Icons.add,
        ),
        SizedBox(height: spacing.medium),
        GlimmerListItem(
          label: 'Immersive controls',
          supportingLabel: 'Dim everything but the focused surface',
          trailing: GlimmerSwitch(
            value: _immersive,
            label: 'Immersive controls',
            onChanged: (value) => setState(() => _immersive = value),
          ),
        ),
        SizedBox(height: spacing.large),
        GlimmerProgressBar(value: _progress),
        SizedBox(height: spacing.small),
        Slider(
          value: _progress,
          onChanged: (value) => setState(() => _progress = value),
        ),
      ],
    );
  }
}

class _FoundationsPage extends StatelessWidget {
  const _FoundationsPage({
    required this.scale,
    required this.onScaleChanged,
    required this.mode,
    required this.onModeChanged,
  });

  final GlimmerScale scale;
  final ValueChanged<GlimmerScale> onScaleChanged;
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final type = tokens.typography;
    final spacing = tokens.spacing;

    final swatches = <String, Color>{
      'primary': colors.primary,
      'secondary': colors.secondary,
      'positive': colors.positive,
      'negative': colors.negative,
      'surface': colors.surface,
      'outline': colors.outline,
    };

    final styles = <String, TextStyle>{
      'titleLarge': type.titleLarge,
      'titleMedium': type.titleMedium,
      'titleSmall': type.titleSmall,
      'bodyLarge': type.bodyLarge,
      'bodyMedium': type.bodyMedium,
      'bodySmall': type.bodySmall,
      'caption': type.caption,
    };

    return ListView(
      padding: EdgeInsets.fromLTRB(spacing.large, 24, spacing.large, 24),
      children: [
        const _SectionLabel('Ground'),
        SizedBox(height: spacing.small),
        Text(
          'Glimmer is dark by necessity on a lens. On a phone it does not have '
          'to be.',
          style: type.caption.copyWith(color: colors.outline),
        ),
        SizedBox(height: spacing.medium),
        GlimmerButtonGroup(
          children: [
            GlimmerToggleButton(
              label: 'Dark',
              selected: mode == ThemeMode.dark,
              onChanged: (_) => onModeChanged(ThemeMode.dark),
            ),
            GlimmerToggleButton(
              label: 'Light',
              selected: mode == ThemeMode.light,
              onChanged: (_) => onModeChanged(ThemeMode.light),
            ),
          ],
        ),
        SizedBox(height: spacing.extraLarge),

        const _SectionLabel('Scale'),
        SizedBox(height: spacing.small),
        Text(
          'The same tokens at two thirds, or at the published glasses sizes.',
          style: type.caption.copyWith(color: colors.outline),
        ),
        SizedBox(height: spacing.medium),
        GlimmerButtonGroup(
          children: [
            GlimmerToggleButton(
              label: 'Mobile',
              selected: scale == GlimmerScale.mobile,
              onChanged: (_) => onScaleChanged(GlimmerScale.mobile),
            ),
            GlimmerToggleButton(
              label: 'Glasses',
              selected: scale == GlimmerScale.glasses,
              onChanged: (_) => onScaleChanged(GlimmerScale.glasses),
            ),
          ],
        ),
        SizedBox(height: spacing.extraLarge),
        const _SectionLabel('Colour'),
        SizedBox(height: spacing.medium),
        Wrap(
          spacing: spacing.medium,
          runSpacing: spacing.medium,
          children: [
            for (final entry in swatches.entries)
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 44,
                    decoration: BoxDecoration(
                      color: entry.value,
                      borderRadius: tokens.shapes.small,
                      border: Border.all(color: colors.outline, width: 1.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(entry.key, style: type.caption),
                ],
              ),
          ],
        ),
        SizedBox(height: spacing.extraLarge),
        const _SectionLabel('Type'),
        SizedBox(height: spacing.medium),
        for (final entry in styles.entries) ...[
          Text(entry.key, style: entry.value),
          Text(
            '${entry.value.fontSize!.toStringAsFixed(1)} px, '
            'w${entry.value.fontWeight!.value}',
            style: type.caption.copyWith(color: colors.outline),
          ),
          SizedBox(height: spacing.medium),
        ],
        SizedBox(height: spacing.large),
        const _SectionLabel('Depth'),
        SizedBox(height: spacing.small),
        Text(
          'Five levels, two black shadow layers each. Components rest flat and '
          'take a level while focused.',
          style: type.caption.copyWith(color: colors.outline),
        ),
        SizedBox(height: spacing.medium),
        // The shadows are black, so on the black window colour they are
        // invisible. They are shown over a gradient for the same reason the
        // upstream depth reference is.
        ClipRRect(
          borderRadius: tokens.shapes.medium,
          child: Stack(
            children: [
              const _Backdrop(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.large,
                  vertical: spacing.extraLarge * 2,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: spacing.extraLarge,
                  runSpacing: spacing.extraLarge * 2,
                  children: [
                    for (var level = 1; level <= 5; level++)
                      GlimmerSurface(
                        depth: tokens.depth[level],
                        padding: EdgeInsets.zero,
                        child: SizedBox(
                          width: 72,
                          height: 64,
                          child: Center(
                            child: Text('+$level', style: type.titleSmall),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    return Text(
      text.toUpperCase(),
      style: tokens.typography.caption.copyWith(
        color: tokens.colors.secondary,
        letterSpacing: 1.2,
      ),
    );
  }
}

/// A warm gradient standing in for a camera pass-through, so the surfaces on
/// top of it have something worth filtering.
class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: GlimmerBackdrop(
        colors: [
          Color(0xFF3E6B80),
          Color(0xFF8A7434),
          Color(0xFF54406B),
        ],
      ),
    );
  }
}

class _AboutSheet extends StatelessWidget {
  const _AboutSheet();

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(tokens.spacing.large),
      child: GlimmerSurface(
        depth: tokens.depth.level4,
        additive: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('material_glimmer', style: tokens.typography.titleMedium),
            SizedBox(height: tokens.spacing.extraSmall),
            Text(
              'Version 1.0.0 · MIT',
              style: tokens.typography.caption.copyWith(
                color: tokens.colors.secondary,
              ),
            ),
            SizedBox(height: tokens.spacing.medium),
            Text(
              'A design system for Flutter: a theme, a full token set and a '
              'widget library, picked the way you pick Material or Cupertino. '
              'Surfaces are glass over whatever you put behind them, focus is '
              'a lit edge, and depth is a real shadow.',
              style: tokens.typography.bodySmall,
            ),
            SizedBox(height: tokens.spacing.medium),
            Text(
              'Everything is drawn rather than shipped as assets, and Flutter '
              'is the only dependency.',
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.colors.outline,
              ),
            ),
            SizedBox(height: tokens.spacing.large),
            GlimmerButton(
              label: 'Close',
              expand: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
