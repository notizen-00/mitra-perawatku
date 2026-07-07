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

  static Map<String, String> defaultHeaders({String? token}) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}
