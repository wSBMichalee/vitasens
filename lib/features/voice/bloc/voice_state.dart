import 'package:equatable/equatable.dart';

abstract class VoiceState extends Equatable {
  const VoiceState();

  @override
  List<Object?> get props => [];
}

class VoiceInitial extends VoiceState {
  const VoiceInitial();
}

class VoiceListening extends VoiceState {
  final bool isListening;

  const VoiceListening({this.isListening = true});

  @override
  List<Object?> get props => [isListening];
}

class VoiceProcessing extends VoiceState {
  final String transcribedText;

  const VoiceProcessing(this.transcribedText);

  @override
  List<Object?> get props => [transcribedText];
}

class VoiceResult extends VoiceState {
  final String transcribedText;
  final Map<String, dynamic> parsedMeal;

  const VoiceResult({
    required this.transcribedText,
    required this.parsedMeal,
  });

  @override
  List<Object?> get props => [transcribedText, parsedMeal];
}

class VoiceLogged extends VoiceState {
  final bool success;

  const VoiceLogged({this.success = true});

  @override
  List<Object?> get props => [success];
}

class VoiceError extends VoiceState {
  final String message;

  const VoiceError(this.message);

  @override
  List<Object?> get props => [message];
}
