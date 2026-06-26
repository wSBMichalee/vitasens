import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/detect/bloc/detect_event.dart';
import 'package:vitasense/features/detect/bloc/detect_state.dart';
import 'package:vitasense/features/detect/data/detect_repository.dart';

class DetectBloc extends Bloc<DetectEvent, DetectState> {
  final DetectRepository repository;

  DetectBloc({required this.repository}) : super(const DetectInitial()) {
    on<CapturePhoto>(_onCapturePhoto);
    on<ScanBarcode>(_onScanBarcode);
    on<SwitchMode>(_onSwitchMode);
    on<ScanFridge>(_onScanFridge);
  }

  Future<void> _onCapturePhoto(
    CapturePhoto event,
    Emitter<DetectState> emit,
  ) async {
    emit(const DetectProcessing());
    try {
      final result = await repository.detectFood(
        photoBase64: event.photoBase64,
        mealTime: event.mealTime,
      );
      emit(DetectSuccess(result));
    } catch (e) {
      emit(DetectError(e.toString()));
    }
  }

  Future<void> _onScanBarcode(
    ScanBarcode event,
    Emitter<DetectState> emit,
  ) async {
    emit(const DetectProcessing());
    try {
      final result = await repository.scanBarcode(event.barcode);
      emit(DetectSuccess(result));
    } catch (e) {
      emit(DetectError(e.toString()));
    }
  }

  void _onSwitchMode(
    SwitchMode event,
    Emitter<DetectState> emit,
  ) {
    emit(const DetectInitial());
  }

  Future<void> _onScanFridge(
    ScanFridge event,
    Emitter<DetectState> emit,
  ) async {
    emit(const DetectProcessing());
    try {
      final result = await repository.scanFridge(
        imageBase64: event.imageBase64,
        mode: event.mode,
      );
      final products = (result['products'] as List?) ?? [];
      emit(DetectFridgeSuccess(products, event.mode));
    } catch (e) {
      emit(DetectError(e.toString()));
    }
  }
}
