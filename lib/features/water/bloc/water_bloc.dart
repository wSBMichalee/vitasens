import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'water_event.dart';
import 'water_state.dart';
import '../data/water_repository.dart';

class WaterBloc extends Bloc<WaterEvent, WaterState> {
  final WaterRepository _repository;

  WaterBloc({WaterRepository? repository}) 
      : _repository = repository ?? WaterRepository(),
        super(WaterLoading()) {
    on<LoadWater>(_onLoadWater);
    on<AddWater>(_onAddWater);
  }

  Future<void> _onLoadWater(LoadWater event, Emitter<WaterState> emit) async {
    try {
      emit(WaterLoading());
      final consumed = await _repository.getTodayWater();
      
      final userId = Supabase.instance.client.auth.currentUser?.id;
      int goal = 2500; // default
      if (userId != null) {
        final profileResp = await Supabase.instance.client
            .from('profiles')
            .select('daily_water_target')
            .eq('id', userId)
            .maybeSingle();
        if (profileResp != null && profileResp['daily_water_target'] != null) {
          goal = profileResp['daily_water_target'] as int;
        }
      }

      emit(WaterLoaded(consumedMl: consumed, goalMl: goal));
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  Future<void> _onAddWater(AddWater event, Emitter<WaterState> emit) async {
    if (state is WaterLoaded) {
      final currentState = state as WaterLoaded;
      try {
        await _repository.addWater(event.amountMl);
        emit(currentState.copyWith(consumedMl: currentState.consumedMl + event.amountMl));
      } catch (e) {
        // Here we could emit error or handle it, but for simplicity let's just emit current state
        // and log error, or emit WaterError. If we emit WaterError we lose loaded state, 
        // better to re-emit loaded after small error indication if needed.
        emit(WaterError(e.toString()));
      }
    }
  }
}
