# Native identity and entry points

Raysto targets Android and iOS. Both platforms display **Raysto** and use the user-selected application identity `com.gmrt.raysto`. The iOS Debug, Release and Profile app configurations use that identifier; the test bundle uses the `.RunnerTests` suffix. The rebuilt 0.3.0+3 ARM64 Android preview was checked with `aapt` and `apksigner` for this identity. Earlier runtime checks in validation.md used the previous provisional ID and do not establish runtime behavior for this newly identified build.

## Branding

The launcher mark is original simple fork-and-knife geometry in lime `#D7F978` on forest `#173F35`. It follows the in-app restaurant mark without copying a third-party logo. Android uses `res/drawable/raysto_launcher.xml`; branded density PNGs are retained as fallbacks. The iOS asset catalog contains opaque PNGs at every size listed in its manifest, including the 1024-pixel marketing icon; iOS applies its native corner mask.

Launch surfaces use paper `#F6F7F2` with the same forest/lime mark. Android includes night resources and Android 12+ splash attributes. The application then applies the saved semantic light/dark theme and matching system-bar icons. The iOS launch storyboard uses the paper background and 108-point mark.

The icons and launch images can be regenerated on Windows with:

```powershell
./ios/tools/generate_brand_assets.ps1
```

This uses .NET vector drawing primitives, has no network dependencies, and reads the iOS asset manifest to determine required sizes. It does not transform any source photograph. The Android vector and drawing script are the editable source artwork.

## Custom-scheme links

The native projects register the local `raysto` URL scheme. Supported example entry points are:

| URL | Destination |
| --- | --- |
| `raysto://app/item/olive-bowl` | Garden bowl, current menu and modifier validation |
| `raysto://table/olive/olive-table-06` | Physical table confirmation; never automatic admission to another party |
| `raysto://app/visit/visit-06` | Visit details, only for a participant or authorized staff |
| `raysto://app/order/<order-id>` | Scoped order detail or useful access/unavailable state |
| `raysto://app/scan` | Local QR/payload scan demonstration |
| `raysto://app/gallery` | Isolated component gallery |
| `raysto://app/preferences` | Preferences |

Android registers the listed `app` paths and the `table` host. The previous foundation's `/dish/` paths remain registered but now show useful unavailable-link recovery; use `/item/` for the current menu. The intent filter has `autoVerify="false"`. iOS registers the scheme in `CFBundleURLTypes`; its application router owns path/host handling. Both projects explicitly enable Flutter's built-in deep-link handler. An unauthenticated link opens entry; personal content still requires the intended account and scope. Invitation codes use a separate confirmation and explicit join action.

These are custom-scheme links, **not verified Android App Links or iOS Universal Links**. No domain association, website, `assetlinks.json`, associated-domain entitlement or AASA file is configured. A future Node.js web application remains separate work. Scheme registration also does not reserve exclusive ownership of the word `raysto` across installed applications.

Native link invocation can be checked on an installed app with Android's `adb shell am start -W -a android.intent.action.VIEW -d "raysto://app/item/olive-bowl" com.gmrt.raysto`, or on an iOS simulator with `xcrun simctl openurl booted "raysto://app/item/olive-bowl"`. Repeat while the app is cold, running, and backgrounded, and inspect back navigation. See `validation.md` for the exact invocations actually verified.

Configuration follows the official [Android deep-link intent-filter documentation](https://developer.android.com/training/app-links/create-deeplinks), [Apple custom URL scheme documentation](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app), and [Flutter deep-link handling documentation](https://docs.flutter.dev/ui/navigation/deep-linking).

## Checks performed on the native resources

XML parsing succeeded for the native manifest/plist/storyboard and all seven Android drawable/style XML resources. All 19 iOS app-icon manifest entries resolve to files with the expected dimensions and opaque RGB pixel format. The 1024-pixel icon and launch mark were visually inspected. This source/asset verification does not establish native build success, installation, link dispatch or launch rendering; see `validation.md` for actual runtime/build evidence.
