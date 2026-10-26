# Asset provenance

The separate Next.js web application's generated editorial images, original 3D geometry, drawn motifs and Fraunces typography are documented in [web creative direction](web-creative-direction.md). They do not replace the native app assets described below.

Downloaded and inspected on 24 October 2026. Assets are bundled locally so the preview does not depend on image or font requests at runtime.

The exact runtime asset files, byte sizes and SHA-256 checksums are recorded in [assets-manifest.json](assets-manifest.json). The Plus Jakarta Sans OS/2 tables were inspected: weights are 400, 500, 600 and 700 respectively, and these four files are static (no variable `fvar` table). Noto Sans Arabic is a separately bundled variable font. All three photographs were visually inspected for subject/content matching.

## Typography

Plus Jakarta Sans was designed by Gumpita Rahayu / Tokotype. The four files below are official static TTF weights from the [upstream project](https://github.com/tokotype/PlusJakartaSans/tree/master/fonts/ttf), not synthetic bold styles or converted web fonts.

| Local file | Weight | Source |
| --- | --- | --- |
| `assets/fonts/PlusJakartaSans-Regular.ttf` | 400 | [Official Regular TTF](https://raw.githubusercontent.com/tokotype/PlusJakartaSans/master/fonts/ttf/PlusJakartaSans-Regular.ttf) |
| `assets/fonts/PlusJakartaSans-Medium.ttf` | 500 | [Official Medium TTF](https://raw.githubusercontent.com/tokotype/PlusJakartaSans/master/fonts/ttf/PlusJakartaSans-Medium.ttf) |
| `assets/fonts/PlusJakartaSans-SemiBold.ttf` | 600 | [Official SemiBold TTF](https://raw.githubusercontent.com/tokotype/PlusJakartaSans/master/fonts/ttf/PlusJakartaSans-SemiBold.ttf) |
| `assets/fonts/PlusJakartaSans-Bold.ttf` | 700 | [Official Bold TTF](https://raw.githubusercontent.com/tokotype/PlusJakartaSans/master/fonts/ttf/PlusJakartaSans-Bold.ttf) |

License: SIL Open Font License 1.1. The unmodified upstream notice is retained at `assets/fonts/OFL.txt`. Copyright 2020 The Plus Jakarta Sans Project Authors. The files are registered as family `PlusJakartaSans` with their respective real weights.

Arabic uses the official [Noto Sans Arabic variable TTF](https://github.com/google/fonts/blob/main/ofl/notosansarabic/NotoSansArabic%5Bwdth%2Cwght%5D.ttf), acquired from the Google Fonts repository and bundled unchanged as `assets/fonts/NotoSansArabic.ttf`. Its [upstream OFL notice](https://github.com/google/fonts/blob/main/ofl/notosansarabic/OFL.txt) is retained at `assets/licenses/NotoSansArabic-OFL.txt`. `AppTheme` and shared type styles register `NotoSansArabic` as the fallback family, so Arabic rendering does not need a font download. Product UI supports English, French and Arabic; authored fixture names remain in their source language.

## Icons

The existing foundation and developer studio use the official [phosphor_flutter package](https://pub.dev/packages/phosphor_flutter), version 2.1.0, under the MIT License. The unmodified upstream notice is retained at `assets/licenses/phosphor_flutter-LICENSE.txt`; dependency licensing remains part of Flutter's package license handling. New product screens use the Flutter SDK's Material outlined icons through its normal `uses-material-design` asset handling.

The maintained integration exposes `PhosphorIcons.regular.<name>` and `PhosphorIcons.fill.<name>`, accepted by native Flutter `Icon` or the package's `PhosphorIcon`. Regular and fill styles preserve a coherent visual system; duotone rendering requires the package widget if introduced. The [upstream manifest](https://github.com/phosphor-icons/phosphor-flutter/blob/master/pubspec.yaml) declares Dart `>=2.12.0 <4.0.0` and Flutter `>=1.17.0`. Application dependency resolution and release packaging must still be checked against the installed SDK; a declared version range alone is not build evidence.

## Photography

All three photographs were downloaded from their source image links with JPEG output, width 1200 and quality 85. No pixel editing was applied. Widgets may crop them to their display aspect ratio. These are illustrative stock photos for authored sample dishes, not photographs of a real partner restaurant or evidence of ingredients/allergens.

| Local file | Photographer and source | Pixels | Content / use |
| --- | --- | --- | --- |
| `assets/images/salad_bowl.jpg` | [Anna Pelzer — bowl of vegetable salads](https://unsplash.com/photos/bowl-of-vegetable-salads-IGfIGP5ONV0) | 1200 × 800 | Wide overhead bowl with avocado, chickpeas, sweet potato and vegetables; seasonal bowl / feature image |
| `assets/images/tomato_pasta.jpg` | [Elena Leya — pasta with tomatoes and basil](https://unsplash.com/photos/a-plate-of-pasta-with-tomatoes-and-basil-usCnVPut-98) | 1200 × 1800 | Farfalle with cherry tomatoes and basil; tomato pasta |
| `assets/images/wood_fired_pizza.jpg` | [Joanie Simon — wood-fired pizza](https://unsplash.com/photos/a-pizza-on-a-white-plate-on-a-table-T0q4_yyQ4Hg) | 1200 × 1800 | Tomato, mozzarella and basil pizza; wood-fired pizza |

Each source identifies the image as free under the [Unsplash License](https://unsplash.com/license), permitting download, modification and use including commercial projects. The license excludes unmodified photo resale and compiling images to reproduce a competing photo service. Photographer credit is preserved here even though the license does not require attribution. These are standard Unsplash photographs, not Unsplash+ assets.

Direct downloaded image origins:

- Salad: `https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&fm=jpg&q=85&w=1200`
- Pasta: `https://images.unsplash.com/photo-1671523557969-14e564017d09?auto=format&fit=crop&fm=jpg&q=85&w=1200`
- Pizza: `https://images.unsplash.com/photo-1682264788192-9abdec90c425?auto=format&fit=crop&fm=jpg&q=85&w=1200`

## Authored import fixture

`assets/fixtures/olive-menu.pdf` is an original, fictional Olive Kitchen menu authored by `tool/create_menu_fixture.py` with ReportLab. `assets/fixtures/olive-menu.png` is its bundled rendered preview. The four fixture entries deliberately include an unclear lemonade price (`EUR 3.?0`) and missing soup dietary information, making the import-review correction tasks concrete. These are not photographs or a scanned third-party restaurant menu. The document states its local-demo purpose. Importing it selects deterministic local extraction data and never uploads a document or calls a live AI service.

The PDF uses standard PDF Helvetica fonts; these fixture fonts do not replace the app's Jakarta/Arabic interface typography. The generator is retained for review and regeneration. The asset manifest includes both PDF and preview hashes.

## Native brand artwork

The forest/lime fork-and-knife launcher mark is original geometric artwork authored for Raysto, with editable Android vector XML at `android/app/src/main/res/drawable/raysto_launcher.xml`. The reproducible .NET drawing script at `ios/tools/generate_brand_assets.ps1` generates the corresponding iOS app icons, iOS launch images and Android density fallbacks. No photograph or third-party trademark was used to produce it. See [native platform setup](native-platforms.md).

## Supplied material

`ui/1.png` through `ui/14.png` are user-supplied reference concepts. They remain reference material and are not shipped as app imagery. The user-supplied guide is preserved verbatim in `docs/MOBILE_APP_DESIGN_SYSTEM_GUIDELINES.md`. No rights to reuse unrelated imagery, identities or commercial brands from reference screenshots are assumed.
