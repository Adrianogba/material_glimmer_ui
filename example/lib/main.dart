import 'package:flutter/material.dart';
import 'package:material_glimmer_ui/material_glimmer_ui.dart';

void main() => runApp(const MaterialGlimmerGallery());

/// The gallery app.
class MaterialGlimmerGallery extends StatefulWidget {
  /// Creates the gallery.
  const MaterialGlimmerGallery({super.key});

  @override
  State<MaterialGlimmerGallery> createState() => _MaterialGlimmerGalleryState();
}

class _MaterialGlimmerGalleryState extends State<MaterialGlimmerGallery> {
  var _mode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialGlimmerApp(
      title: 'Material Glimmer UI',
      debugShowCheckedModeBanner: false,
      // The package ships no assets, so the typeface is the app's to choose.
      // Every style in the kit flows from the theme, so setting it once here
      // covers every piece of text in the gallery.
      fontFamily: 'Google Sans Flex',
      themeMode: _mode,
      home: _GalleryHome(
        mode: _mode,
        onModeChanged: (mode) => setState(() => _mode = mode),
      ),
    );
  }
}

class _GalleryHome extends StatefulWidget {
  const _GalleryHome({
    required this.mode,
    required this.onModeChanged,
  });

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
      const _FoundationsPage(),
    ];

    return GlimmerScaffold(
      backdrop: const GlimmerBackdrop(),
      title: 'Material Glimmer UI',
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
            onPressed: () => showGlimmerDialog<void>(
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
  var _refreshed = false;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final type = tokens.typography;
    final spacing = tokens.spacing;

    // Pull the page down past the top: the edge lights, holds and breathes
    // while the work runs, and nothing on the page moves.
    return GlimmerRefreshIndicator(
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 1400));
        if (mounted) setState(() => _refreshed = true);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(spacing.large, 24, spacing.large, 24),
        children: [
          Text('An interface\nwith atmosphere.', style: type.titleLarge),
          SizedBox(height: spacing.medium),
          Text(
            _refreshed
                ? 'Refreshed. Surfaces filter what is behind them instead of '
                    'covering it, and pulling this page lit the edge instead of '
                    'sliding a spinner over it.'
                : 'Surfaces filter what is behind them instead of covering it. '
                    'Focus is a lit edge rather than a ripple. Pull this page '
                    'down past the top and the edge lights instead of stretching.',
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
                        height:
                            GlimmerTitleChipDefaults.associatedContentSpacing(
                                context),
                      ),
                      const GlimmerCard(
                        title: 'Arrive 10:08',
                        supportingText: 'Six minutes on foot, mostly shade',
                        leadingIcon: Icons.directions_walk,
                      ),
                      SizedBox(height: spacing.medium),
                      // No tint at all: the surface adds nothing and only blurs
                      // what is behind it, so all there is to see is the backdrop
                      // out of focus and the lit edge around it.
                      const GlimmerCard(
                        opacity: 0,
                        blur: 22,
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
      ),
    );
  }
}

class _ComponentsPage extends StatefulWidget {
  const _ComponentsPage();

  @override
  State<_ComponentsPage> createState() => _ComponentsPageState();
}

/// Roughly the height of the gallery's own navigation strip, so a message
/// clears it instead of landing on top.
const _navigationStripHeight = 76.0;

class _ComponentsPageState extends State<_ComponentsPage> {
  final _bought = <String>{};
  var _muted = false;
  var _listening = true;
  var _immersive = false;
  var _progress = 0.4;
  var _digest = true;
  var _roast = 'Medium';
  var _filter = 0;
  var _query = '';
  final _tags = <String>{'Open now'};
  var _loading = true;

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

  Future<void> _openDialog(BuildContext context) async {
    final leaving = await showGlimmerDialog<bool>(
      context: context,
      builder: (context) => GlimmerDialog(
        icon: Icons.storefront,
        title: 'Leave the queue?',
        content: 'You are third in line at the Mercado Municipal.',
        actions: [
          GlimmerButton(
            label: 'Stay',
            onPressed: () => Navigator.of(context).pop(false),
          ),
          GlimmerButton(
            label: 'Leave',
            prominent: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (leaving == true && context.mounted) {
      showGlimmerSnackbar(
        context,
        message: 'You left the queue',
        bottomInset: _navigationStripHeight,
      );
    }
  }

  Future<void> _openSheet(BuildContext context) async {
    final choice = await showGlimmerBottomSheet<String>(
      context: context,
      builder: (context) => GlimmerBottomSheet(
        title: 'Sort the market list',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in const ['By aisle', 'By price', 'Alphabetical'])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlimmerListItem(
                  label: option,
                  leadingIcon: Icons.sort,
                  onTap: () => Navigator.of(context).pop(option),
                ),
              ),
          ],
        ),
      ),
    );
    if (choice != null && context.mounted) {
      showGlimmerSnackbar(
        context,
        message: 'Sorted $choice',
        bottomInset: _navigationStripHeight,
      );
    }
  }

  Future<void> _openMenu(BuildContext context) async {
    final choice = await showGlimmerMenu<String>(
      context: context,
      items: const [
        GlimmerMenuItem(
          label: 'Share the list',
          value: 'share',
          icon: Icons.ios_share,
        ),
        GlimmerMenuItem(
          label: 'Duplicate',
          value: 'duplicate',
          icon: Icons.copy_all_outlined,
        ),
        GlimmerMenuItem(
          label: 'Not available offline',
          value: 'offline',
          icon: Icons.cloud_off,
          enabled: false,
        ),
        GlimmerMenuItem(
          label: 'Delete the list',
          value: 'delete',
          icon: Icons.delete_outline,
          destructive: true,
        ),
      ],
    );
    if (choice != null && context.mounted) {
      showGlimmerSnackbar(
        context,
        message: 'Chose $choice',
        bottomInset: _navigationStripHeight,
      );
    }
  }

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
        const _SectionLabel('Choosing'),
        SizedBox(height: spacing.small),
        Text(
          'A tick that is drawn on, a dot that springs out, and a marker that '
          'slides between choices.',
          style:
              tokens.typography.caption.copyWith(color: tokens.colors.outline),
        ),
        SizedBox(height: spacing.medium),
        GlimmerCheckbox(
          value: _digest,
          label: 'Send me the weekly digest',
          onChanged: (value) => setState(() => _digest = value),
        ),
        for (final roast in const ['Light', 'Medium', 'Dark'])
          GlimmerRadio<String>(
            value: roast,
            groupValue: _roast,
            label: '$roast roast',
            onChanged: (value) => setState(() => _roast = value),
          ),
        SizedBox(height: spacing.medium),
        GlimmerTabs(
          labels: const ['All', 'Open', 'Closed'],
          selectedIndex: _filter,
          onChanged: (index) => setState(() => _filter = index),
        ),
        SizedBox(height: spacing.medium),
        GlimmerChipGroup(
          children: [
            for (final tag in const ['Open now', 'Outdoors', 'Free entry'])
              GlimmerChip(
                label: tag,
                icon: _tags.contains(tag) ? Icons.check : null,
                selected: _tags.contains(tag),
                onPressed: () => setState(
                  () =>
                      _tags.contains(tag) ? _tags.remove(tag) : _tags.add(tag),
                ),
              ),
            GlimmerChip(
              label: 'Santos',
              avatar: const GlimmerAvatar(label: 'Santos', size: 20),
              onDeleted: () {},
            ),
          ],
        ),
        SizedBox(height: spacing.extraLarge),
        const _SectionLabel('Waiting'),
        SizedBox(height: spacing.small),
        Text(
          'A placeholder is the shape of what is coming with light passing '
          'over it, not a grey block with a band sliding behind a window.',
          style:
              tokens.typography.caption.copyWith(color: tokens.colors.outline),
        ),
        SizedBox(height: spacing.medium),
        GlimmerCard(
          child: _loading
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlimmerSkeleton(
                      width: 40,
                      height: 40,
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                    SizedBox(width: spacing.medium),
                    Expanded(child: GlimmerSkeleton.lines()),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlimmerAvatar(label: 'Ana Ribeiro'),
                    SizedBox(width: spacing.medium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ana Ribeiro',
                              style: tokens.typography.titleSmall),
                          SizedBox(height: spacing.extraSmall),
                          Text(
                            'Left a note about the delivery window on '
                            'Thursday morning.',
                            style: tokens.typography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        SizedBox(height: spacing.medium),
        GlimmerButton(
          label: _loading ? 'Load the content' : 'Back to waiting',
          expand: true,
          onPressed: () => setState(() => _loading = !_loading),
        ),
        SizedBox(height: spacing.extraLarge),
        const _SectionLabel('Small pieces'),
        SizedBox(height: spacing.medium),
        GlimmerSearchField(
          hint: 'Search the list',
          onChanged: (value) => setState(() => _query = value),
        ),
        SizedBox(height: spacing.medium),
        Row(
          children: [
            const GlimmerAvatar(label: 'Ana Ribeiro'),
            SizedBox(width: spacing.medium),
            const GlimmerAvatar(icon: Icons.storefront, size: 32),
            SizedBox(width: spacing.large),
            GlimmerBadge(
              count: _query.isEmpty ? 3 : _query.length,
              child: GlimmerIconButton(
                icon: Icons.notifications_outlined,
                tooltip: 'Notifications',
                onPressed: () {},
              ),
            ),
            SizedBox(width: spacing.large),
            const GlimmerCircularProgress(size: 32),
            SizedBox(width: spacing.medium),
            const GlimmerCircularProgress(value: 0.65, size: 32),
          ],
        ),
        SizedBox(height: spacing.large),
        const GlimmerDivider(),
        SizedBox(height: spacing.large),
        const GlimmerExpansionTile(
          label: 'Delivery',
          supportingLabel: 'Thursday, before noon',
          leadingIcon: Icons.local_shipping_outlined,
          children: [
            GlimmerListItem(
              label: 'Leave with a neighbour',
              leadingIcon: Icons.home_outlined,
            ),
            GlimmerListItem(
              label: 'Ring the bell twice',
              leadingIcon: Icons.notifications_active_outlined,
            ),
          ],
        ),
        SizedBox(height: spacing.extraLarge),
        const _SectionLabel('Screens'),
        SizedBox(height: spacing.small),
        Text(
          'A pushed screen arrives instead of sliding, and the one behind it '
          'withdraws rather than moving away.',
          style:
              tokens.typography.caption.copyWith(color: tokens.colors.outline),
        ),
        SizedBox(height: spacing.medium),
        GlimmerButton(
          label: 'Open a screen',
          leadingIcon: Icons.open_in_new,
          onPressed: () => Navigator.of(context).push(
            GlimmerPageRoute<void>(builder: (context) => const _DetailScreen()),
          ),
        ),
        SizedBox(height: spacing.extraLarge),
        const _SectionLabel('Overlays'),
        SizedBox(height: spacing.small),
        Text(
          'A panel over a blurred app, a sheet from the bottom, a message that '
          'leaves on its own, a menu against its anchor.',
          style:
              tokens.typography.caption.copyWith(color: tokens.colors.outline),
        ),
        SizedBox(height: spacing.medium),
        Wrap(
          spacing: spacing.medium,
          runSpacing: spacing.medium,
          children: [
            GlimmerButton(
              label: 'Dialog',
              leadingIcon: Icons.chat_outlined,
              onPressed: () => _openDialog(context),
            ),
            GlimmerButton(
              label: 'Sheet',
              leadingIcon: Icons.vertical_align_bottom,
              onPressed: () => _openSheet(context),
            ),
            GlimmerButton(
              label: 'Message',
              leadingIcon: Icons.campaign_outlined,
              onPressed: () => showGlimmerSnackbar(
                context,
                message: 'Added to the Saturday market list',
                icon: Icons.check_circle_outline,
                actionLabel: 'Undo',
                onAction: () {},
                bottomInset: _navigationStripHeight,
              ),
            ),
            Builder(
              builder: (context) => GlimmerButton(
                label: 'Menu',
                leadingIcon: Icons.more_horiz,
                onPressed: () => _openMenu(context),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.extraLarge),
        const _SectionLabel('Input'),
        SizedBox(height: spacing.small),
        Text(
          'A field, a switch, a bar and a slider, all drawn from the same '
          'tokens as everything above.',
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
        SizedBox(height: spacing.medium),
        GlimmerSlider(
          value: _progress,
          semanticLabel: 'Progress',
          onChanged: (value) => setState(() => _progress = value),
        ),
        SizedBox(height: spacing.large),
        Text(
          'With no value, a highlight travels the track instead of a block '
          'sliding along it.',
          style:
              tokens.typography.caption.copyWith(color: tokens.colors.outline),
        ),
        SizedBox(height: spacing.medium),
        const GlimmerProgressBar(),
      ],
    );
  }
}

class _FoundationsPage extends StatelessWidget {
  const _FoundationsPage();

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
          'Five levels, and none of them is a shadow. Glimmer says how high '
          'something sits by taking the plane behind it away, so nothing casts '
          'anything: a dialog at level 4 makes the app under it withdraw by '
          'that much.',
          style: type.caption.copyWith(color: colors.outline),
        ),
        SizedBox(height: spacing.medium),
        for (var level = 1; level <= 5; level++) ...[
          Row(
            children: [
              SizedBox(
                width: 64,
                child: Text('Level $level', style: type.caption),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: tokens.shapes.small,
                  child: SizedBox(
                    height: 28,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const _Backdrop(),
                        ColoredBox(
                          color: colors.background.withValues(
                            alpha: tokens.depth[level].recede,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.small),
        ],
      ],
    );
  }
}

/// The screen [GlimmerPageRoute] pushes, so the arrival has something to
/// arrive with.
class _DetailScreen extends StatelessWidget {
  const _DetailScreen();

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final spacing = tokens.spacing;

    return GlimmerScaffold(
      backdrop: const GlimmerBackdrop(),
      title: 'Museu do Café',
      leading: GlimmerIconButton(
        icon: Icons.arrow_back,
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(spacing.large, 24, spacing.large, 24),
        children: [
          const GlimmerCard(
            leadingIcon: Icons.museum_outlined,
            title: 'Santos, open until five',
            supportingText: 'The old coffee exchange, kept as it was.',
          ),
          SizedBox(height: spacing.medium),
          const GlimmerCard(
            leadingIcon: Icons.directions_walk,
            title: 'Arrive 10:08',
            supportingText: 'Six minutes on foot, mostly shade',
          ),
          SizedBox(height: spacing.medium),
          GlimmerButton(
            label: 'Back',
            expand: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
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
    return Padding(
      padding: EdgeInsets.all(tokens.spacing.large),
      child: GlimmerSurface(
        additive: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('material_glimmer_ui', style: tokens.typography.titleMedium),
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
              'a lit edge, and depth is the plane behind withdrawing rather '
              'than a shadow in front.',
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
