import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_mitra.dart';
import '../../domain/usecases/register_mitra.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required LoginMitra loginMitra,
    required RegisterMitra registerMitra,
  }) : _loginMitra = loginMitra,
       _registerMitra = registerMitra,
       super(const AuthInitial());

  final LoginMitra _loginMitra;
  final RegisterMitra _registerMitra;

  Future<void> login({
    required String email,
    required String password,
    required LoginRole role,
  }) async {
    emit(const AuthLoading());

    try {
      final result = await _loginMitra(
        email: email,
        password: password,
        role: role,
      );
      emit(AuthSuccess(result));
    } on Failure catch (error) {
      emit(AuthError(error.message));
    } catch (_) {
      emit(const AuthError('Login gagal. Silakan coba lagi.'));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String profession,
    required String specialization,
    required String licenseNumber,
    String? workLocation,
    int? yearsOfExperience,
    double? consultationFee,
    String? bio,
  }) async {
    emit(const AuthLoading());

    try {
      final result = await _registerMitra(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        profession: profession,
        specialization: specialization,
        licenseNumber: licenseNumber,
        workLocation: workLocation,
        yearsOfExperience: yearsOfExperience,
        consultationFee: consultationFee,
        bio: bio,
      );
      emit(AuthSuccess(result));
    } on Failure catch (error) {
      emit(AuthError(error.message));
    } catch (_) {
      emit(const AuthError('Pendaftaran gagal. Silakan coba lagi.'));
    }
  }
}
