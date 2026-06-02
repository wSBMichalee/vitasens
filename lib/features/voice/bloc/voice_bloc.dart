import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vitasense/features/voice/bloc/voice_event.dart';
import 'package:vitasense/features/voice/bloc/voice_state.dart';
import 'package:vitasense/features/voice/data/voice_repository.dart';

class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
  final VoiceRepository _repository;
  final SpeechToText _speech = SpeechToText();

  VoiceBloc({VoiceRepository? repository})
      : _repository = repository ?? VoiceRepository(),
        super(const VoiceInitial()) {
    on<StartListening>(_onStartListening);
    on<StopListening>(_onStopListening);
    on<ParseSpeech>(_onParseSpeech);
    on<LogMeal>(_onLogMeal);
    on<ClearVoice>(_onClearVoice);
  }

  Future<void> _onStartListening(
    StartListening event,
    Emitter<VoiceState> emit,
  ) async {
    emit(const VoiceListening());
    try {
      final available = await _speech.initialize(
        onError: (error) => add(const ClearVoice()), // lub log error
      );
      if (available) {
        _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              add(ParseSpeech(result.recognizedWords));
            }
          },
        );
      } else {
        emit(const VoiceError('Speech recognition not available.'));
      }
    } catch (e) {
      emit(VoiceError(e.toString()));
    }
  }

  Future<void> _onStopListening(
    StopListening event,
    Emitter<VoiceState> emit,
  ) async {
    if (_speech.isListening) {
      await _speech.stop();
    }
    // Ewentualnie wymusić przetworzenie ostatniego słowa lub poczekać na finalResult z listen,
    // Tutaj zostawiamy po prostu w trybie processing póki co
    emit(const VoiceProcessing('Finalizing speech...'));
  }

  Future<void> _onParseSpeech(
    ParseSpeech event,
    Emitter<VoiceState> emit,
  ) async {
    emit(VoiceProcessing(event.text));
    try {
      final parsedMeal = await _repository.parseSpeech(event.text);
      emit(VoiceResult(
        transcribedText: event.text,
        parsedMeal: parsedMeal,
      ));
    } catch (e) {
      emit(VoiceError(e.toString()));
    }
  }

  Future<void> _onLogMeal(
    LogMeal event,
    Emitter<VoiceState> emit,
  ) async {
    emit(const VoiceProcessing('Logging meal...'));
    try {
      await _repository.logMeal(event.mealData);
      emit(const VoiceLogged());
    } catch (e) {
      emit(VoiceError(e.toString()));
    }
  }

  void _onClearVoice(
    ClearVoice event,
    Emitter<VoiceState> emit,
  ) {
    if (_speech.isListening) {
      _speech.stop();
    }
    emit(const VoiceInitial());
  }
}
