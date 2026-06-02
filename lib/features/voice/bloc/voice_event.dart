import 'package:equatable/equatable.dart';

abstract class VoiceEvent extends Equatable {
  const VoiceEvent();

  @override
  List<Object?> get props => [];
}

class StartListening extends VoiceEvent {
  const StartListening();
}

class StopListening extends VoiceEvent {
  const StopListening();
}

class ParseSpeech extends VoiceEvent {
  final String text;

  const ParseSpeech(this.text);

  @override
  List<Object?> get props => [text];
}

class LogMeal extends VoiceEvent {
  final Map<String, dynamic> mealData;

  const LogMeal(this.mealData);

  @override
  List<Object?> get props => [mealData];
}

class ClearVoice extends VoiceEvent {
  const ClearVoice();
}
