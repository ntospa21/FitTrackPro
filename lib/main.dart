import 'package:fit_track_pro/screens/login_screen.dart';
import 'package:fit_track_pro/screens/main_menu_screen.dart';
import 'package:fit_track_pro/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

final _router = GoRouter(initialLocation: '/', routes: [
  GoRoute(
      name: 'splash',
      path: '/',
      builder: (context, state) => const SplashScreen()),
  GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen()),
  GoRoute(
      path: '/main-menu',
      name: 'mainMenu',
      builder: (context, state) => const MainMenuScreen()),
]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}
