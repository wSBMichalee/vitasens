import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();

  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
  ];

  Future<bool> requestPermissions() async {
    try {
      await Permission.activityRecognition.request();
      final permissions = _types.map((_) => HealthDataAccess.READ).toList();
      final granted = await _health.requestAuthorization(_types, permissions: permissions);
      return granted;
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasPermissions() async {
    try {
      final permissions = _types.map((_) => HealthDataAccess.READ).toList();
      final result = await _health.hasPermissions(_types, permissions: permissions);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, int>> getTodayData() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final data = await _health.getHealthDataFromTypes(
        startTime: midnight,
        endTime: now,
        types: _types,
      );

      final deduplicated = Health().removeDuplicates(data);

      int steps = 0;
      int activeCalories = 0;

      for (final point in deduplicated) {
        final value = (point.value as NumericHealthValue).numericValue.toInt();
        if (point.type == HealthDataType.STEPS) {
          steps += value;
        } else if (point.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
          activeCalories += value;
        }
      }

      return {
        'steps': steps,
        'activeCalories': activeCalories,
      };
    } catch (e) {
      return {'steps': 0, 'activeCalories': 0};
    }
  }
}
