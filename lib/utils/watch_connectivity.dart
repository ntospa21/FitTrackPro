// watch_connectivity_service.dart
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class WatchConnectivityService {
  static const platform = MethodChannel('com.fittrackpro/watch');

  Stream<Map<String, dynamic>>? _dataStream;
  Stream<bool>? _connectionStream;

  // Setup method channel listener
  void initialize() {
    platform.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    print('Received method call: ${call.method}');

    switch (call.method) {
      case 'onWatchData':
        final data = Map<String, dynamic>.from(call.arguments as Map);
        print('Watch data received: $data');
        _dataStreamController.add(data);
        break;
      case 'onWatchConnectionChanged':
        final isConnected = call.arguments as bool;
        print('Watch connection changed: $isConnected');
        _connectionStreamController.add(isConnected);
        break;
    }
  }

  final _dataStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStreamController = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get watchDataStream =>
      _dataStreamController.stream;
  Stream<bool> get connectionStream => _connectionStreamController.stream;

  Future<void> startWorkout() async {
    try {
      await platform.invokeMethod('startWorkout');
      print('Start workout command sent');
    } catch (e) {
      print('Error starting workout: $e');
    }
  }

  Future<void> stopWorkout() async {
    try {
      await platform.invokeMethod('stopWorkout');
      print('Stop workout command sent');
    } catch (e) {
      print('Error stopping workout: $e');
    }
  }

  Future<bool> isWatchConnected() async {
    try {
      final result = await platform.invokeMethod('isWatchConnected');
      return result as bool;
    } catch (e) {
      print('Error checking watch connection: $e');
      return false;
    }
  }

  Future<void> refreshConnection() async {
    try {
      await platform.invokeMethod('refreshConnection');
    } catch (e) {
      print('Error refreshing connection: $e');
    }
  }

  void dispose() {
    _dataStreamController.close();
    _connectionStreamController.close();
  }
}

// Providers
final watchConnectivityServiceProvider =
    Provider<WatchConnectivityService>((ref) {
  final service = WatchConnectivityService();
  service.initialize();
  return service;
});

final watchConnectionProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(watchConnectivityServiceProvider);
  return service.connectionStream;
});

final watchDataProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(watchConnectivityServiceProvider);
  return service.watchDataStream;
});

// Watch Workout State
class WatchWorkoutState {
  final bool isActive;
  final int heartRate;
  final int calories;
  final int steps;
  final double distance;
  final int duration;

  WatchWorkoutState({
    this.isActive = false,
    this.heartRate = 0,
    this.calories = 0,
    this.steps = 0,
    this.distance = 0.0,
    this.duration = 0,
  });

  factory WatchWorkoutState.fromMap(Map<String, dynamic> map) {
    return WatchWorkoutState(
      isActive: map['isActive'] as bool? ?? false,
      heartRate: map['heartRate'] as int? ?? 0,
      calories: map['calories'] as int? ?? 0,
      steps: map['steps'] as int? ?? 0,
      distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
      duration: map['duration'] as int? ?? 0,
    );
  }

  WatchWorkoutState copyWith({
    bool? isActive,
    int? heartRate,
    int? calories,
    int? steps,
    double? distance,
    int? duration,
  }) {
    return WatchWorkoutState(
      isActive: isActive ?? this.isActive,
      heartRate: heartRate ?? this.heartRate,
      calories: calories ?? this.calories,
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
    );
  }
}

final watchWorkoutStateProvider =
    StateNotifierProvider<WatchWorkoutNotifier, WatchWorkoutState>((ref) {
  return WatchWorkoutNotifier(ref);
});

class WatchWorkoutNotifier extends StateNotifier<WatchWorkoutState> {
  final Ref ref;

  WatchWorkoutNotifier(this.ref) : super(WatchWorkoutState()) {
    _listenToWatchData();
  }

  void _listenToWatchData() {
    ref.listen(watchDataProvider, (previous, next) {
      next.whenData((data) {
        final type = data['type'] as String?;
        if (type == 'liveData' || type == 'workoutComplete') {
          state = WatchWorkoutState.fromMap(data);
          print(
              'Updated workout state: HR=${state.heartRate}, Steps=${state.steps}');
        }
      });
    });
  }

  Future<void> startWorkout() async {
    final service = ref.read(watchConnectivityServiceProvider);
    await service.startWorkout();
  }

  Future<void> stopWorkout() async {
    final service = ref.read(watchConnectivityServiceProvider);
    await service.stopWorkout();
  }
}
