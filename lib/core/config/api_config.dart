enum ApiEnvironment { production, docker, laragon }

class ApiConfig {
  const ApiConfig._();

  static const ApiEnvironment environment = ApiEnvironment.production;

  static String get baseUrl {
    return switch (environment) {
      ApiEnvironment.production => 'https://backend.perawatku.tech',
      ApiEnvironment.docker => 'http://localhost:8081',
      ApiEnvironment.laragon => 'http://medic-app.test',
    };
  }

  static String get apiBaseUrl => '$baseUrl/api';

  static String get reverbKey => 'medic-app-key';

  static Uri get reverbUri {
    final (scheme, host, port) = switch (environment) {
      ApiEnvironment.production => ('wss', 'backend.perawatku.tech', 443),
      ApiEnvironment.docker => ('ws', 'localhost', 8080),
      ApiEnvironment.laragon => ('ws', '127.0.0.1', 8080),
    };

    return Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: '/app/$reverbKey',
      queryParameters: const {
        'protocol': '7',
        'client': 'flutter',
        'version': '1.0.0',
        'flash': 'false',
      },
    );
  }

  static Map<String, String> defaultHeaders({String? token}) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}
