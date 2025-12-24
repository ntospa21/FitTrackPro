import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

// Watch connectivity channel
const watchChannel = MethodChannel('com.fittrackpro/watch');

// Workout state provider
final workoutStateProvider =
    StateNotifierProvider<WorkoutStateNotifier, WorkoutState>((ref) {
  return WorkoutStateNotifier();
});

// Workout state
class WorkoutState {
  final bool isActive;
  final bool isWatchConnected;
  final int steps;
  final double distance;
  final int duration;
  final int calories;
  final int heartRate;

  WorkoutState({
    this.isActive = false,
    this.isWatchConnected = false,
    this.steps = 0,
    this.distance = 0.0,
    this.duration = 0,
    this.calories = 0,
    this.heartRate = 0,
  });

  WorkoutState copyWith({
    bool? isActive,
    bool? isWatchConnected,
    int? steps,
    double? distance,
    int? duration,
    int? calories,
    int? heartRate,
  }) {
    return WorkoutState(
      isActive: isActive ?? this.isActive,
      isWatchConnected: isWatchConnected ?? this.isWatchConnected,
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      heartRate: heartRate ?? this.heartRate,
    );
  }
}

class WorkoutStateNotifier extends StateNotifier<WorkoutState> {
  WorkoutStateNotifier() : super(WorkoutState()) {
    _setupWatchListener();
    _checkWatchConnection();
  }

  void _setupWatchListener() {
    watchChannel.setMethodCallHandler((call) async {
      print('Flutter received: ${call.method} - ${call.arguments}');

      if (call.method == 'onWatchData') {
        final data = Map<String, dynamic>.from(call.arguments);
        _updateFromWatch(data);
      } else if (call.method == 'onWatchConnectionChanged') {
        final isConnected = call.arguments as bool;
        print('Watch connection changed: $isConnected');
        state = state.copyWith(isWatchConnected: isConnected);
      }
    });
  }

  Future<void> _checkWatchConnection() async {
    try {
      final isConnected =
          await watchChannel.invokeMethod<bool>('isWatchConnected') ?? false;
      print('Initial watch connection status: $isConnected');
      state = state.copyWith(isWatchConnected: isConnected);
    } catch (e) {
      print('Error checking watch connection: $e');
      state = state.copyWith(isWatchConnected: false);
    }
  }

  void _updateFromWatch(Map<String, dynamic> data) {
    print('Updating from watch data: $data');

    final type = data['type'] as String?;

    if (type == 'workoutStatus') {
      final isActive = data['isActive'] as bool? ?? state.isActive;
      print('Workout status update - isActive: $isActive');
      state = state.copyWith(isActive: isActive);
    } else if (type == 'liveData' || type == 'workoutComplete') {
      state = state.copyWith(
        heartRate: data['heartRate'] as int? ?? state.heartRate,
        calories: data['calories'] as int? ?? state.calories,
        steps: data['steps'] as int? ?? state.steps,
        distance: (data['distance'] as num?)?.toDouble() ?? state.distance,
        duration: data['duration'] as int? ?? state.duration,
        isActive: data['isActive'] as bool? ?? state.isActive,
      );
      print(
          'Live data update - isActive: ${state.isActive}, heartRate: ${state.heartRate}');
    }
  }

  Future<void> startWorkout() async {
    try {
      print('Starting workout from Flutter');
      await watchChannel.invokeMethod('startWorkout');
      state = state.copyWith(isActive: true);
    } catch (e) {
      print('Error starting workout: $e');
    }
  }

  Future<void> stopWorkout() async {
    try {
      print('Stopping workout from Flutter');
      await watchChannel.invokeMethod('stopWorkout');
      state = state.copyWith(isActive: false);
    } catch (e) {
      print('Error stopping workout: $e');
    }
  }

  Future<void> refreshConnection() async {
    try {
      print('Refreshing connection');
      await watchChannel.invokeMethod('refreshConnection');
      await _checkWatchConnection();
    } catch (e) {
      print('Error refreshing connection: $e');
    }
  }

  Future<void> requestWatchAccess() async {
    try {
      print('Requesting watch access');
      await watchChannel.invokeMethod('requestWatchAccess');
      await _checkWatchConnection();
    } catch (e) {
      print('Error requesting watch access: $e');
    }
  }

  void resetWorkout() {
    state = WorkoutState(isWatchConnected: state.isWatchConnected);
  }
}

// Workout Screen
class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

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

  void _showWatchConnectionDialog(BuildContext context, WidgetRef ref) {
    final workoutNotifier = ref.read(workoutStateProvider.notifier);
    final workoutState = ref.read(workoutStateProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(24),
              Icon(
                workoutState.isWatchConnected
                    ? Icons.watch
                    : Icons.watch_off_outlined,
                size: 64,
                color:
                    workoutState.isWatchConnected ? Colors.green : Colors.grey,
              ),
              const Gap(16),
              Text(
                workoutState.isWatchConnected
                    ? 'Apple Watch Connected'
                    : 'Apple Watch Not Connected',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Gap(8),
              Text(
                workoutState.isWatchConnected
                    ? 'Your Apple Watch is connected and ready to track workouts.'
                    : 'Connect your Apple Watch to track heart rate, steps, and more.',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Gap(24),
              if (!workoutState.isWatchConnected) ...[
                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To connect your Apple Watch:',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      const Gap(8),
                      _buildInstructionRow(
                          '1', 'Make sure Bluetooth is enabled'),
                      _buildInstructionRow(
                          '2', 'Open FitTrack Pro on your Apple Watch'),
                      _buildInstructionRow(
                          '3', 'Keep both devices close together'),
                      _buildInstructionRow(
                          '4', 'Tap "Refresh Connection" below'),
                    ],
                  ),
                ),
                const Gap(16),
              ],
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        workoutNotifier.refreshConnection();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Refreshing connection...',
                              style: GoogleFonts.roboto(),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh),
                          const Gap(8),
                          Text(
                            'Refresh Connection',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const Gap(8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstructionRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Gap(8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 13,
                color: Colors.blue[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(workoutStateProvider);
    final workoutNotifier = ref.read(workoutStateProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Walking Workout',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Watch connection indicator - Tappable
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => _showWatchConnectionDialog(context, ref),
              icon: Stack(
                children: [
                  Icon(
                    Icons.watch,
                    color: workoutState.isWatchConnected
                        ? Colors.green
                        : Colors.grey,
                    size: 28,
                  ),
                  if (!workoutState.isWatchConnected)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                  if (workoutState.isWatchConnected)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                ],
              ),
              tooltip: 'Apple Watch Connection',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Watch Connection Banner
              if (!workoutState.isWatchConnected)
                GestureDetector(
                  onTap: () => _showWatchConnectionDialog(context, ref),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.watch_off, color: Colors.orange),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            'Apple Watch not connected. Tap to connect.',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: Colors.orange[900],
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.orange,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),

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
                          ? 'Workout Active'
                          : 'Ready to Start',
                      style: GoogleFonts.roboto(
                        fontSize: 24,
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
                  childAspectRatio: 1.3,
                  children: [
                    _buildStatCard(
                      icon: Icons.favorite,
                      title: 'Heart Rate',
                      value: '${workoutState.heartRate} bpm',
                      color: Colors.red,
                    ),
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
                      value: '${workoutState.calories} kcal',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              const Gap(24),

              // Control Buttons
              Row(
                children: [
                  if (!workoutState.isActive) ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: workoutState.isWatchConnected
                            ? () => workoutNotifier.startWorkout()
                            : () => _showWatchConnectionDialog(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: workoutState.isWatchConnected
                              ? Colors.green
                              : Colors.grey[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(workoutState.isWatchConnected
                                ? Icons.play_arrow
                                : Icons.watch),
                            const Gap(8),
                            Text(
                              workoutState.isWatchConnected
                                  ? 'Start Workout'
                                  : 'Connect Watch',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => workoutNotifier.stopWorkout(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.stop),
                            const Gap(8),
                            Text(
                              'Stop',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (workoutState.duration > 0 && !workoutState.isActive) ...[
                    const Gap(12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => workoutNotifier.resetWorkout(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.refresh),
                            const Gap(8),
                            Text(
                              'Reset',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
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
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
