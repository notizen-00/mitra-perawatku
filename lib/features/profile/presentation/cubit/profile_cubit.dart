import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/mitra_profile.dart';
import '../../domain/usecases/get_profile.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._getProfile) : super(const ProfileInitial());

  final GetProfile _getProfile;

  Future<void> load() async {
    emit(const ProfileLoading());
    try {
      emit(ProfileLoaded(await _getProfile()));
    } on Failure catch (error) {
      emit(ProfileError(error.message));
    } catch (_) {
      emit(const ProfileError('Profil belum bisa dimuat.'));
    }
  }
}
