import 'package:equatable/equatable.dart';

import 'auth_user.dart';

class AuthResult extends Equatable {
  const AuthResult({required this.user, required this.token});

  final AuthUser user;
  final String token;

  @override
  List<Object?> get props => [user, token];
}
