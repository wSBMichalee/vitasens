import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/family/bloc/family_event.dart';
import 'package:vitasense/features/family/bloc/family_state.dart';
import 'package:vitasense/features/family/data/family_repository.dart';

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  final FamilyRepository _repository;

  FamilyBloc({FamilyRepository? repository})
      : _repository = repository ?? FamilyRepository(),
        super(const FamilyInitial()) {
    on<LoadFamily>(_onLoadFamily);
    on<CreateFamily>(_onCreateFamily);
    on<JoinFamily>(_onJoinFamily);
    on<LeaveFamily>(_onLeaveFamily);
    on<DeleteFamily>(_onDeleteFamily);
  }

  Future<void> _onLoadFamily(
    LoadFamily event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    try {
      final family = await _repository.getMyFamily();
      if (family == null) {
        emit(const FamilyNoGroup());
      } else {
        emit(FamilyLoaded(family));
      }
    } catch (e) {
      emit(FamilyError(_parseError(e)));
    }
  }

  Future<void> _onCreateFamily(
    CreateFamily event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    try {
      final family = await _repository.createFamily(event.name);
      emit(FamilyLoaded(family));
    } catch (e) {
      emit(FamilyError(_parseError(e)));
      add(const LoadFamily());
    }
  }

  Future<void> _onJoinFamily(
    JoinFamily event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    try {
      final family = await _repository.joinFamily(event.inviteCode);
      emit(FamilyLoaded(family));
    } catch (e) {
      emit(FamilyError(_parseError(e)));
      add(const LoadFamily());
    }
  }

  Future<void> _onLeaveFamily(
    LeaveFamily event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    try {
      await _repository.leaveFamily();
      emit(const FamilyNoGroup());
    } catch (e) {
      emit(FamilyError(_parseError(e)));
      add(const LoadFamily());
    }
  }

  Future<void> _onDeleteFamily(
    DeleteFamily event,
    Emitter<FamilyState> emit,
  ) async {
    emit(const FamilyLoading());
    try {
      await _repository.deleteFamily();
      emit(const FamilyNoGroup());
    } catch (e) {
      emit(FamilyError(_parseError(e)));
      add(const LoadFamily());
    }
  }

  // ─── Error Parser ──────────────────────────────────────────────────────────────
  String _parseError(dynamic e) {
    final raw = e.toString().toLowerCase();

    if (raw.contains('already')) return 'You are already in a family group.';
    if (raw.contains('not found')) {
      return 'Invalid invite code. Please check and try again.';
    }
    if (raw.contains('full')) return 'This family group is full (max 6 members).';
    if (raw.contains('network') ||
        raw.contains('socket') ||
        raw.contains('connection')) {
      return 'No internet connection.';
    }
    return 'Could not update family group. Try again.';
  }
}
