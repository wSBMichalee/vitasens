abstract class WaterState {}

class WaterLoading extends WaterState {}

class WaterLoaded extends WaterState {
  final int consumedMl;
  final int goalMl;

  WaterLoaded({required this.consumedMl, required this.goalMl});

  WaterLoaded copyWith({int? consumedMl, int? goalMl}) {
    return WaterLoaded(
      consumedMl: consumedMl ?? this.consumedMl,
      goalMl: goalMl ?? this.goalMl,
    );
  }
}

class WaterError extends WaterState {
  final String message;
  WaterError(this.message);
}
