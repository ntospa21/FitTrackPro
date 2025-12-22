import 'package:fit_track_pro/main.dart';
import 'package:fit_track_pro/pallete/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Animation for the linear progress bar
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // total duration of progress
    )..forward();

    // Navigate to next screen after the progress completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Example navigation
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));

        // context.go('/main-menu');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Title and subtitle at the top
              const SizedBox(height: 40),
              Text(
                "FitTrackPro",
                style: GoogleFonts.roboto(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                "Monitor your health and workouts",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              // SVG in the middle
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/fit_splash.png',
                    height: 300,
                  ),
                ),
              ),

              // Get Started button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: AppColors.backgroundGrey,
                  ),
                  child: Text(
                    "Get Started",
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Linear progress bar at the bottom
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _controller.value,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    color: Theme.of(context).primaryColor,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
