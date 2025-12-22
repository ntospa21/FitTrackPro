import 'package:fit_track_pro/screens/login_screen.dart';
import 'package:fit_track_pro/screens/main_menu_screen.dart';
import 'package:fit_track_pro/screens/splash_screen.dart';
import 'package:go_router/go_router.dart';

final _router = GoRouter(initialLocation: '/splash', routes: [
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
