import 'package:equatable/equatable.dart';

abstract class DetectEvent extends Equatable {
  const DetectEvent();

  @override
  List<Object?> get props => [];
}

class CapturePhoto extends DetectEvent {
  final String photoBase64;
  final String mealTime;

  const CapturePhoto(this.photoBase64, this.mealTime);

  @override
  List<Object?> get props => [photoBase64, mealTime];
}

class ScanBarcode extends DetectEvent {
  final String barcode;

  const ScanBarcode(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class SwitchMode extends DetectEvent {
  final String mode; // meal/fridge/receipt

  const SwitchMode(this.mode);

  @override
  List<Object?> get props => [mode];
}
