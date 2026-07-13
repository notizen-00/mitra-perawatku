import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/models/auth_user_model.dart';
import '../../features/auth/domain/entities/auth_user.dart';
import '../config/api_config.dart';

class AuthSession {
  AuthSession(this._storage);

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final FlutterSecureStorage _storage;

  String? _token;
  int? _userId;
  AuthUser? _user;

  String? get token => _token;
  int? get userId => _userId;
  AuthUser? get user => _user;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Map<String, String> get headers => ApiConfig.defaultHeaders(token: _token);

  Future<void> restore() async {
    final token = await _storage.read(key: _tokenKey);
    final userPayload = await _storage.read(key: _userKey);

    if (token == null || token.isEmpty) {
      clearMemory();
      return;
    }

    _token = token;

    if (userPayload == null || userPayload.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(userPayload);
      if (decoded is Map<String, dynamic>) {
        _user = AuthUserModel.fromJson(decoded);
        _userId = _user?.id;
      }
    } on FormatException {
      await clear();
    }
  }

  Future<void> save({
    required String token,
    int? userId,
    AuthUser? user,
  }) async {
    _token = token;
    _user = user;
    _userId = user?.id ?? userId;

    await _storage.write(key: _tokenKey, value: token);

    if (user != null) {
      final model = AuthUserModel.fromEntity(user);
      await _storage.write(key: _userKey, value: jsonEncode(model.toJson()));
    }
  }

  Future<void> clear() async {
    clearMemory();
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  void clearMemory() {
    _token = null;
    _userId = null;
    _user = null;
  }
}
