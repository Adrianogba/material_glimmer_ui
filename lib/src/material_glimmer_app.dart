import 'package:flutter/material.dart';

import 'glimmer_scroll.dart';
import 'glimmer_theme.dart';

/// The application widget, alongside `MaterialApp` and `CupertinoApp`.
///
/// It sets up the Glimmer theme, navigation and localisation in one place, so
/// an app that has chosen Glimmer never has to build a [ThemeData] by hand:
///
/// ```dart
/// void main() => runApp(
///   const MaterialGlimmerApp(
///     title: 'Bakery',
///     home: HomeScreen(),
///   ),
/// );
/// ```
///
/// Under the hood this is a `MaterialApp` carrying [GlimmerTheme.dark]. That is
/// deliberate. Material's app widget is where Flutter's routing, localisation
/// delegates, scroll behaviour and text selection controls live, and
/// reimplementing them would buy nothing but bugs. What Glimmer replaces is the
/// look and the interaction model, and those come from the theme.
///
/// Because it is a real Material app, a Material widget dropped next to a
/// Glimmer one inherits the Glimmer palette and type rather than clashing with
/// it. Adopt the whole system, or move over one screen at a time.
///
/// Pass [theme] to take over the theme entirely. The [primary], [scale],
/// [fontFamily] and [additive] arguments are ignored when you do.
class MaterialGlimmerApp extends StatelessWidget {
  /// Creates a Glimmer app using the [Navigator] API.
  const MaterialGlimmerApp({
    super.key,
    this.navigatorKey,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.dark,
    this.primary,
    this.scale = GlimmerScale.mobile,
    this.fontFamily,
    this.additive,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.showPerformanceOverlay = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.scrollBehavior,
  })  : routeInformationProvider = null,
        routeInformationParser = null,
        routerDelegate = null,
        routerConfig = null,
        backButtonDispatcher = null,
        _isRouter = false;

  /// Creates a Glimmer app using the Router API, for `go_router` and friends.
  const MaterialGlimmerApp.router({
    super.key,
    this.routeInformationProvider,
    this.routeInformationParser,
    this.routerDelegate,
    this.routerConfig,
    this.backButtonDispatcher,
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.dark,
    this.primary,
    this.scale = GlimmerScale.mobile,
    this.fontFamily,
    this.additive,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.showPerformanceOverlay = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
    this.restorationScopeId,
    this.scrollBehavior,
  })  : navigatorKey = null,
        home = null,
        routes = const <String, WidgetBuilder>{},
        initialRoute = null,
        onGenerateRoute = null,
        onGenerateInitialRoutes = null,
        onUnknownRoute = null,
        navigatorObservers = const <NavigatorObserver>[],
        _isRouter = true;

  final bool _isRouter;

  /// A key for the app's [Navigator].
  final GlobalKey<NavigatorState>? navigatorKey;

  /// The widget for the default route.
  final Widget? home;

  /// The app's named routes.
  final Map<String, WidgetBuilder> routes;

  /// The name of the first route.
  final String? initialRoute;

  /// Builds a route for a name not in [routes].
  final RouteFactory? onGenerateRoute;

  /// Builds the initial route stack.
  final InitialRouteListFactory? onGenerateInitialRoutes;

  /// Builds a route when everything else has failed.
  final RouteFactory? onUnknownRoute;

  /// Observers for the app's [Navigator].
  final List<NavigatorObserver> navigatorObservers;

  /// Wraps every route, for things like a persistent overlay.
  final TransitionBuilder? builder;

  /// The app's title, shown in the task switcher.
  final String title;

  /// Builds a localised title.
  final GenerateAppTitle? onGenerateTitle;

  /// Replaces the theme.
  ///
  /// It fills Material's light slot, and it also stands in for the dark one
  /// unless [darkTheme] is given as well. Since [themeMode] defaults to dark,
  /// passing a single theme here does what you would expect rather than
  /// quietly applying to a mode the app is not in.
  ///
  /// Leave it null to get [GlimmerTheme.light] built from [primary], [scale],
  /// [fontFamily] and [additive].
  final ThemeData? theme;

  /// Replaces the dark Glimmer theme.
  ///
  /// Leave it null to fall back to [theme], and then to [GlimmerTheme.dark]
  /// built from the same arguments.
  final ThemeData? darkTheme;

  /// Which of the two themes to use.
  ///
  /// The default is [ThemeMode.dark], because Glimmer is a dark system and a
  /// light Glimmer app should be a deliberate choice rather than something the
  /// device decides. Pass [ThemeMode.system] to follow the device anyway; both
  /// themes are always built, so nothing else has to change.
  final ThemeMode themeMode;

  /// The focal colour, used for focused outlines and prominent fills.
  ///
  /// Defaults to `#9BBFFF` on dark and to its light-ground counterpart on
  /// light.
  final Color? primary;

  /// Which of the two measurement sets to use.
  final GlimmerScale scale;

  /// The typeface. This package ships no assets, so it is whatever font your
  /// app already has, or the platform default.
  final String? fontFamily;

  /// Whether surfaces add their tint to the backdrop. See
  /// [GlimmerTokens.additive]. Defaults to true on dark and false on light.
  final bool? additive;

  /// Forces a locale instead of using the device's.
  final Locale? locale;

  /// Delegates producing localised resources.
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// Resolves the locale from the device's preferred list.
  final LocaleListResolutionCallback? localeListResolutionCallback;

  /// Resolves the locale from a single device locale.
  final LocaleResolutionCallback? localeResolutionCallback;

  /// The locales this app has been translated to.
  final Iterable<Locale> supportedLocales;

  /// Whether to overlay a performance graph.
  final bool showPerformanceOverlay;

  /// Whether to show the debug banner in debug builds.
  final bool debugShowCheckedModeBanner;

  /// Default keyboard shortcuts.
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// Default actions for the shortcuts.
  final Map<Type, Action<Intent>>? actions;

  /// The restoration scope id for state restoration.
  final String? restorationScopeId;

  /// The app's scroll behaviour.
  ///
  /// Defaults to [GlimmerScrollBehavior], which drops the overscroll stretch.
  /// The stretch renders the scrolling content into an offscreen layer, and a
  /// surface that reads what is behind it finds nothing there, so every glass
  /// panel on the screen goes opaque for as long as the stretch lasts.
  final ScrollBehavior? scrollBehavior;

  /// Supplies route information to [routerDelegate].
  final RouteInformationProvider? routeInformationProvider;

  /// Parses route information into a configuration.
  final RouteInformationParser<Object>? routeInformationParser;

  /// Builds the navigating widget from the configuration.
  final RouterDelegate<Object>? routerDelegate;

  /// A single object holding the whole Router configuration.
  final RouterConfig<Object>? routerConfig;

  /// Reports back button presses to the router.
  final BackButtonDispatcher? backButtonDispatcher;

  @override
  Widget build(BuildContext context) {
    final light = theme ??
        GlimmerTheme.light(
          primary: primary,
          scale: scale,
          fontFamily: fontFamily,
          additive: additive,
        );
    final dark = darkTheme ??
        theme ??
        GlimmerTheme.dark(
          primary: primary,
          scale: scale,
          fontFamily: fontFamily,
          additive: additive,
        );

    if (_isRouter) {
      return MaterialApp.router(
        routeInformationProvider: routeInformationProvider,
        routeInformationParser: routeInformationParser,
        routerDelegate: routerDelegate,
        routerConfig: routerConfig,
        backButtonDispatcher: backButtonDispatcher,
        builder: builder,
        title: title,
        onGenerateTitle: onGenerateTitle,
        theme: light,
        darkTheme: dark,
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: localizationsDelegates,
        localeListResolutionCallback: localeListResolutionCallback,
        localeResolutionCallback: localeResolutionCallback,
        supportedLocales: supportedLocales,
        showPerformanceOverlay: showPerformanceOverlay,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        shortcuts: shortcuts,
        actions: actions,
        restorationScopeId: restorationScopeId,
        scrollBehavior: scrollBehavior ?? const GlimmerScrollBehavior(),
      );
    }

    return MaterialApp(
      navigatorKey: navigatorKey,
      home: home,
      routes: routes,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      onGenerateInitialRoutes: onGenerateInitialRoutes,
      onUnknownRoute: onUnknownRoute,
      navigatorObservers: navigatorObservers,
      builder: builder,
      title: title,
      onGenerateTitle: onGenerateTitle,
      theme: light,
      darkTheme: dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: localizationsDelegates,
      localeListResolutionCallback: localeListResolutionCallback,
      localeResolutionCallback: localeResolutionCallback,
      supportedLocales: supportedLocales,
      showPerformanceOverlay: showPerformanceOverlay,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      shortcuts: shortcuts,
      actions: actions,
      restorationScopeId: restorationScopeId,
      scrollBehavior: scrollBehavior ?? const GlimmerScrollBehavior(),
    );
  }
}
