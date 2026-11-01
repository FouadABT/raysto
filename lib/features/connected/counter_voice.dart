part of 'connected_app.dart';

/// The microphone at the till. The order is recorded into memory as 16 kHz
/// mono PCM and sent once as WAV; nothing is written to the device.
abstract class CounterMic {
  Future<bool> allowed();
  Future<void> start();

  /// Stops and returns the recording as WAV bytes.
  Future<Uint8List> stop();
  Future<void> cancel();
  void dispose();

  /// Replaced in tests with a fake microphone.
  static CounterMic Function() create = _DeviceMic.new;

  /// The server accepts at most 20 seconds of speech.
  static const limit = Duration(seconds: 20);
  static const sampleRate = 16000;
}

class _DeviceMic implements CounterMic {
  final _recorder = AudioRecorder();
  final _pcm = BytesBuilder(copy: false);
  StreamSubscription<Uint8List>? _listening;
  Completer<void>? _ended;

  @override
  Future<bool> allowed() => _recorder.hasPermission();

  @override
  Future<void> start() async {
    _pcm.clear();
    final ended = _ended = Completer<void>();
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: CounterMic.sampleRate,
        numChannels: 1,
        autoGain: true,
        noiseSuppress: true,
      ),
    );
    _listening = stream.listen(
      _pcm.add,
      onDone: () => ended.isCompleted ? null : ended.complete(),
    );
  }

  @override
  Future<Uint8List> stop() async {
    await _recorder.stop();
    // The last samples arrive just before the stream closes.
    await _ended?.future.timeout(const Duration(seconds: 2), onTimeout: () {});
    await _listening?.cancel();
    _listening = null;
    return wavFromPcm16(_pcm.takeBytes(), CounterMic.sampleRate);
  }

  @override
  Future<void> cancel() async {
    await _recorder.cancel();
    await _listening?.cancel();
    _listening = null;
    _pcm.clear();
  }

  @override
  void dispose() {
    _listening?.cancel();
    _recorder.dispose();
  }
}

/// Wraps 16-bit mono PCM in a WAV header.
Uint8List wavFromPcm16(Uint8List pcm, int sampleRate) {
  final header = ByteData(44);
  void text(int at, String s) {
    for (var i = 0; i < s.length; i++) {
      header.setUint8(at + i, s.codeUnitAt(i));
    }
  }

  text(0, 'RIFF');
  header.setUint32(4, 36 + pcm.length, Endian.little);
  text(8, 'WAVE');
  text(12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little); // PCM
  header.setUint16(22, 1, Endian.little); // mono
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, sampleRate * 2, Endian.little);
  header.setUint16(32, 2, Endian.little);
  header.setUint16(34, 16, Endian.little);
  text(36, 'data');
  header.setUint32(40, pcm.length, Endian.little);
  return (BytesBuilder(copy: false)
        ..add(header.buffer.asUint8List())
        ..add(pcm))
      .takeBytes();
}

/// What the voice agent heard, shown above the ticket until the next change.
class VoiceHeard {
  const VoiceHeard(this.added, this.unmatched);
  final List<String> added;
  final List<String> unmatched;
}
