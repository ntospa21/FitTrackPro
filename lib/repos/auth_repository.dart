import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_track_pro/constants/firebase_constants.dart';
import 'package:fit_track_pro/models/custom_error.dart';
import 'package:fit_track_pro/repos/handle_exception.dart';

class AuthRepository {
  User? get currentUser => fbAuth.currentUser;

  Future<void> register(
      {required String name,
      required String email,
      required String password,
      required String gender}) async {
    try {
      final UserCredential = await fbAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final signedInUser = UserCredential.user!;
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      await fbAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> logout() async {
    try {
      await fbAuth.signOut();
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> changePassword({required String password}) async {
    try {
      await currentUser!.updatePassword(password);
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> sendResetPasswordEmail(String email) async {
    try {
      await fbAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await currentUser!.sendEmailVerification();
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> reloadUser() async {
    try {
      await currentUser!.reload();
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> reauthenticateWithCredentials(
      String email, String password) async {
    try {
      await currentUser!.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: email, password: password));
    } catch (e) {
      throw handleException(e);
    }
  }
}
