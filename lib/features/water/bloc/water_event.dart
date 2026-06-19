abstract class WaterEvent {}

class LoadWater extends WaterEvent {
  final DateTime date;
  LoadWater(this.date);
}

class AddWater extends WaterEvent {
  final int amountMl;
  final DateTime date;
  AddWater(this.amountMl, this.date);
}
