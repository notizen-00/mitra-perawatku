import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../config/api_config.dart';
import '../services/auth_session.dart';

class ApiClient {
  ApiClient(this._session, {HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  final AuthSession _session;
  final HttpClient _httpClient;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, Object?>? queryParameters,
  }) {
    return _request(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) {
    return _request(method: 'POST', path: path, body: body);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) {
    return _request(method: 'PATCH', path: path, body: body);
  }

  Future<Map<String, dynamic>> _request({
    required String method,
    required String path,
    Map<String, Object?>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final filteredQuery = queryParameters == null
        ? null
        : Map.fromEntries(
            queryParameters.entries
                .where((entry) => entry.value != null)
                .map((entry) => MapEntry(entry.key, entry.value.toString())),
          );
    final uri = Uri.parse(
      '${ApiConfig.apiBaseUrl}$path',
    ).replace(queryParameters: filteredQuery);

    try {
      final request = await _httpClient
          .openUrl(method, uri)
          .timeout(const Duration(seconds: 20));

      for (final header in _session.headers.entries) {
        request.headers.set(header.key, header.value);
      }

      if (body != null) {
        request.write(jsonEncode(body));
      }

      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      final payload = await response.transform(utf8.decoder).join();
      final decoded = payload.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(payload);

      if (decoded is! Map<String, dynamic>) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Format respons server tidak dikenali.',
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractMessage(decoded),
          errors: decoded['errors'],
        );
      }

      return decoded;
    } on ApiException {
      rethrow;
    } on SocketException catch (error) {
      throw ApiException(statusCode: 0, message: error.message);
    } on TimeoutException {
      throw const ApiException(
        statusCode: 0,
        message: 'Koneksi ke server terlalu lama.',
      );
    } on FormatException {
      throw const ApiException(
        statusCode: 0,
        message: 'Respons server bukan JSON valid.',
      );
    }
  }

  String _extractMessage(Map<String, dynamic> json) {
    final message = json['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    final errors = json['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) {
        return first.first.toString();
      }
      return first.toString();
    }

    return 'Request gagal diproses server.';
  }
}

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });

  final int statusCode;
  final String message;
  final Object? errors;

  @override
  String toString() => message;
}
