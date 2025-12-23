import 'dart:async';
import 'package:fit_track_pro/repos/repository_auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'register_provider.g.dart';

@riverpod
class Register extends _$Register {
  @override
  FutureOr<void> build() {}

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String gender,
  }) async {
    // Registration logic goes here
    state = const AsyncLoading<void>();

    state = await AsyncValue.guard<void>(
        () => ref.read(authRepositoryProvider).register(
              name: name,
              email: email,
              password: password,
              gender: gender,
            ));
  }
}
