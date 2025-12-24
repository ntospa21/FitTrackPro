// UI Screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class AppleWatchWorkoutScreen extends ConsumerWidget {
  const AppleWatchWorkoutScreen({super.key});

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(watchWorkoutStateProvider);
    final connectionAsync = ref.watch(watchConnectionProvider);
    final isConnected = connectionAsync.value ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Apple Watch Workout',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.black,
            ),
            onPressed: () {
              ref.read(watchConnectivityServiceProvider).refreshConnection();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Connection Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isConnected ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isConnected ? Icons.watch : Icons.watch_off,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                    const Gap(8),
                    Text(
                      isConnected
                          ? 'Apple Watch Connected'
                          : 'Apple Watch Not Connected',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        color: isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(24),

              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color:
                      workoutState.isActive ? Colors.green[50] : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_walk,
                      size: 64,
                      color: workoutState.isActive ? Colors.green : Colors.grey,
                    ),
                    const Gap(16),
                    Text(
                      workoutState.isActive
                          ? 'Workout Active on Watch'
                          : 'Ready to Start',
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color:
                            workoutState.isActive ? Colors.green : Colors.black,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      _formatDuration(workoutState.duration),
                      style: GoogleFonts.robotoMono(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (workoutState.isActive)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const Gap(6),
                            Text(
                              'LIVE FROM WATCH',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Gap(24),

              // Stats Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildStatCard(
                      icon: Icons.directions_walk,
                      title: 'Steps',
                      value: workoutState.steps.toString(),
                      color: Colors.blue,
                    ),
                    _buildStatCard(
                      icon: Icons.straighten,
                      title: 'Distance',
                      value: _formatDistance(workoutState.distance),
                      color: Colors.purple,
                    ),
                    _buildStatCard(
                      icon: Icons.local_fire_department,
                      title: 'Calories',
                      value: '${workoutState.calories}',
                      subtitle: 'kcal',
                      color: Colors.orange,
                    ),
                    _buildStatCard(
                      icon: Icons.favorite,
                      title: 'Heart Rate',
                      value: workoutState.heartRate > 0
                          ? workoutState.heartRate.toString()
                          : '--',
                      subtitle: 'bpm',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              const Gap(24),

              // Control Info
              if (!isConnected)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Start workout from your Apple Watch to see live data here',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      color: Colors.orange[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const Gap(8),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (subtitle != null) ...[
                const Gap(4),
                Text(
                  subtitle,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
