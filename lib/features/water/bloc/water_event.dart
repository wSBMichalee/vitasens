abstract class WaterEvent {}

class LoadWater extends WaterEvent {}

class AddWater extends WaterEvent {
  final int amountMl;
  AddWater(this.amountMl);
}
