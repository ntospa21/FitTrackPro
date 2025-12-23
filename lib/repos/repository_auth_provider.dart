import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_track_pro/constants/firebase_constants.dart';
import 'package:fit_track_pro/repos/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repository_auth_provider.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository();
}

@riverpod
Stream<User?> authStateStream(Ref ref) {
  return fbAuth.authStateChanges();
}
