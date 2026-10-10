# DougHubApp

A separate cross-platform app project inspired by DougHub's useful tools, designed to be easier to navigate on iPhone, iPad, and Windows.

## Current starter

- Dark indigo/purple visual style
- Responsive layout: bottom navigation on narrow screens and a sidebar on wider screens
- Home, Tools, Favorites, Recent, and Settings sections
- Searchable starter directory of utility categories
- Adaptive one-, two-, and three-column tool cards

The current screen is a starter interface. The listed tools are directory placeholders until their functionality is implemented.

## Technology

Built with Flutter so the interface and much of the app logic can be shared across iOS, iPadOS, Windows, Android, and the web.

## Development

Install the Flutter SDK, then from the project root run:

```sh
flutter pub get
flutter run -d chrome
```

For Windows desktop development, use a Windows machine with Flutter's Windows desktop requirements installed, then run `flutter run -d windows`.

For iPhone/iPad builds, Flutter's iOS toolchain requires macOS and Xcode. Codespaces can be used for editing, but it cannot directly produce a signed iOS app by itself.

## Next milestones

1. Bring over the useful tools from DougHub's tools directory and implement each one.
2. Add functional favorites and recently used tools.
3. Add settings, local preferences, and accessibility options.
4. Test layouts on phone, tablet, and desktop sizes.
5. Set up platform-specific app icons and packaging.
