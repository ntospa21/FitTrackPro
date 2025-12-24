import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_track_pro/constants/firebase_constants.dart';
import 'package:fit_track_pro/repos/repository_auth_provider.dart';
import 'package:fit_track_pro/routes/routes_names.dart';
import 'package:fit_track_pro/screens/change_password_screen.dart';
import 'package:fit_track_pro/screens/firebase_error_screen.dart';
import 'package:fit_track_pro/screens/login/login_screen.dart';
import 'package:fit_track_pro/screens/main_menu_screen.dart';
import 'package:fit_track_pro/screens/page_not_found.dart';
import 'package:fit_track_pro/screens/register/register_screen.dart';
import 'package:fit_track_pro/screens/splash_screen.dart';
import 'package:fit_track_pro/screens/verify_email.dart';
import 'package:fit_track_pro/screens/workout/workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final authState = ref.watch(authStateStreamProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // If auth state is still loading, stay on the current route (so initial /splash will be shown)
      if (authState is AsyncLoading<User?>) {
        return null;
      }

      // If there's an auth error, go to firebase error screen
      if (authState is AsyncError<User?>) {
        return '/firebaseError';
      }

      final authenticated = authState.asData?.value != null;

      final authenticating = (state.matchedLocation == '/login') ||
          (state.matchedLocation == '/register') ||
          (state.matchedLocation == '/resetPassword');

      if (authenticated == false) {
        return authenticating ? null : '/login';
      }

      // if (!fbAuth.currentUser!.emailVerified) {
      //   return '/verifyEmail';
      // }

      final verifyingEmail = state.matchedLocation == '/verifyEmail';
      final splashing = state.matchedLocation == '/splash';

      return (authenticating || verifyingEmail) ? '/main-menu' : null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: RouteNames.splash,
        builder: (context, state) {
          print('##### Splash #####');
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/firebaseError',
        name: RouteNames.firebaseError,
        builder: (context, state) {
          return const FirebaseErrorScreen();
        },
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        name: RouteNames.register,
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),
      // GoRoute(
      //   path: '/resetPassword',
      //   name: RouteNames.resetPassword,
      //   builder: (context, state) {
      //     return const ResetPasswordPage();
      //   },
      // ),
      GoRoute(
        path: '/verifyEmail',
        name: RouteNames.verifyEmail,
        builder: (context, state) {
          return const VerifyEmailScreen();
        },
      ),
      GoRoute(
        path: '/workout',
        name: RouteNames.workout,
        builder: (context, state) {
          return const WorkoutScreen();
        },
      ),
      GoRoute(
        path: '/main-menu',
        name: RouteNames.home,
        builder: (context, state) {
          return const MainMenuScreen();
        },
        routes: [
          GoRoute(
            path: 'changePassword',
            name: RouteNames.changePassword,
            builder: (context, state) {
              return const ChangePasswordScreen();
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      return PageNotFound(
        errorMessage: state.error.toString(),
      );
    },
  );
}
