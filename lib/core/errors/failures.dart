abstract class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([String? message])
    : super(message ?? 'Terjadi masalah dari server.');
}

class CacheFailure extends Failure {
  const CacheFailure([String? message])
    : super(message ?? 'Gagal membaca data lokal.');
}
