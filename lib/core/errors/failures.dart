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

class NetworkFailure extends Failure {
  const NetworkFailure([String? message])
    : super(message ?? 'Koneksi internet bermasalah.');
}

class ValidationFailure extends Failure {
  const ValidationFailure([String? message])
    : super(message ?? 'Data yang dikirim belum valid.');
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String? message])
    : super(message ?? 'Sesi Anda berakhir. Silakan login kembali.');
}

class CacheFailure extends Failure {
  const CacheFailure([String? message])
    : super(message ?? 'Gagal membaca data lokal.');
}
