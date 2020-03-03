import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPinKey = 'pin_key';

class PinRepository {
  final SharedPreferences sharedPreferences;

  Future<bool> set(String value) =>
      sharedPreferences.setString(_kPinKey, value);

  String get() => sharedPreferences.getString(_kPinKey) ?? '';

  const PinRepository({
    @required this.sharedPreferences,
  });
}
