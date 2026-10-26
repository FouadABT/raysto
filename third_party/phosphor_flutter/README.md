# Flutter 3.47 compatibility subset

Source: phosphor_flutter 2.1.0, https://github.com/phosphor-icons/phosphor-flutter (MIT; see LICENSE).

Flutter 3.47 makes IconData final. The upstream package extends IconData and cannot compile. This local subset retains upstream Regular/Fill constants and original font files, constructing Flutter IconData directly. Existing Raysto gallery glyphs and package font paths stay identical. Duotone, other weights and PhosphorIcon widgets are not included because Raysto does not use them. Do not modify the global pub cache. Revisit this subset when upstream supports current Flutter.
