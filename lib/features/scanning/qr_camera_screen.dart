import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/app_localizations.dart';
import 'raysto_scan_frame.dart';

/// Returns text only. The calling flow validates identity and asks to join.
class QrCameraScreen extends StatefulWidget {
  const QrCameraScreen({super.key});
  @override
  State<QrCameraScreen> createState() => _QrCameraScreenState();
}

class _QrCameraScreenState extends State<QrCameraScreen>
    with WidgetsBindingObserver {
  final _camera = MobileScannerController(
    autoStart: false,
    formats: [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (!mounted || _handled || ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    try {
      await _camera.start();
      if (mounted) setState(() => _error = null);
    } catch (_) {
      if (mounted) setState(() => _error = 'Camera unavailable');
    }
  }

  Future<void> _detect(BarcodeCapture capture) async {
    if (_handled || !mounted) return;
    final text = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .firstOrNull;
    if (text == null || text.length > 2048) return;
    _handled = true;
    try {
      await _camera.stop();
    } catch (_) {}
    if (mounted) Navigator.of(context).pop(text.trim());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_camera.value.hasCameraPermission) return;
    if (state == AppLifecycleState.resumed) {
      unawaited(_start());
    } else {
      unawaited(_camera.stop().catchError((Object _) {}));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_camera.dispose());
    super.dispose();
  }

  Widget _fallback() => Center(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, size: 42),
            const SizedBox(height: 16),
            Text(
              context.tr('Camera unavailable'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              context.tr(
                'Allow camera access in device settings, or enter your table code manually.',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('Enter code instead')),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _preview() => LayoutBuilder(
    builder: (context, constraints) {
      final side = (constraints.biggest.shortestSide - 64).clamp(60.0, 400.0);
      final frame = Rect.fromCenter(
        center: constraints.biggest.center(Offset.zero),
        width: side,
        height: side,
      );
      return Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _camera,
            useAppLifecycleState: false,
            onDetect: _detect,
            scanWindow: frame,
            errorBuilder: (_, _) => _fallback(),
          ),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _camera,
            builder: (_, state, _) => state.isRunning
                ? RaystoScanFrame(window: frame)
                : const SizedBox.shrink(),
          ),
        ],
      );
    },
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.tr('Scan your table')),
      actions: [
        ValueListenableBuilder<MobileScannerState>(
          valueListenable: _camera,
          builder: (context, value, _) => IconButton(
            tooltip: context.tr('Toggle flashlight'),
            onPressed:
                value.isRunning && value.torchState != TorchState.unavailable
                ? () => _camera.toggleTorch().catchError((Object _) {})
                : null,
            icon: Icon(
              value.torchState == TorchState.on
                  ? Icons.flash_on
                  : Icons.flash_off,
            ),
          ),
        ),
      ],
    ),
    body: SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: _error != null ? _fallback() : _preview(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
            child: Text(
              context.tr(
                'Place the QR inside the frame. You will review the table before joining.',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('Enter code instead')),
          ),
        ],
      ),
    ),
  );
}
