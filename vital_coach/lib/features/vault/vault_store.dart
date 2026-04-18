import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VaultStore {
  static const _kPinHash = 'vault_pin_hash_v1';
  static const _kSalt = 'vault_pin_salt_v1';

  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(_kPinHash) ?? '').isNotEmpty &&
        (prefs.getString(_kSalt) ?? '').isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = DateTime.now().microsecondsSinceEpoch.toString();
    final hash = _hash(pin, salt);
    await prefs.setString(_kSalt, salt);
    await prefs.setString(_kPinHash, hash);
  }

  Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final salt = prefs.getString(_kSalt) ?? '';
    final expected = prefs.getString(_kPinHash) ?? '';
    if (salt.isEmpty || expected.isEmpty) return false;
    return _hash(pin, salt) == expected;
  }

  String _hash(String pin, String salt) {
    final bytes = utf8.encode('$salt::$pin');
    return sha256.convert(bytes).toString();
  }
}

