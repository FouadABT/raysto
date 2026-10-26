import 'package:shared_preferences/shared_preferences.dart';

abstract interface class DemoPersistence {
  Future<String?> read();
  Future<void> write(String value);
}

class MemoryDemoPersistence implements DemoPersistence {
  MemoryDemoPersistence([this.value]);
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}

class SharedPreferencesDemoPersistence implements DemoPersistence {
  static const key = 'raysto.demo.world.v1';
  @override
  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(key);
  @override
  Future<void> write(String value) async {
    final saved = await (await SharedPreferences.getInstance()).setString(
      key,
      value,
    );
    if (!saved) throw StateError('The local demo could not be saved.');
  }
}
