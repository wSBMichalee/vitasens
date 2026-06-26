import 'package:equatable/equatable.dart';

abstract class DetectState extends Equatable {
  const DetectState();

  @override
  List<Object?> get props => [];
}

class DetectInitial extends DetectState {
  const DetectInitial();
}

class DetectCapturing extends DetectState {
  const DetectCapturing();
}

class DetectProcessing extends DetectState {
  const DetectProcessing();
}

class DetectSuccess extends DetectState {
  final Map<String, dynamic> result;

  const DetectSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class DetectError extends DetectState {
  final String message;

  const DetectError(this.message);

  @override
  List<Object?> get props => [message];
}

class DetectFridgeSuccess extends DetectState {
  final List<dynamic> products;
  final String mode;

  const DetectFridgeSuccess(this.products, this.mode);

  @override
  List<Object?> get props => [products, mode];
}
