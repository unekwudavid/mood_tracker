import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/mood_entry.dart';
import 'mood_event.dart';
import 'mood_state.dart';

class MoodBloc extends Bloc<MoodEvent, MoodState> {
  MoodBloc() : super(const MoodState()) {
    on<AddMood>(_onAddMood);
    on<ClearMoods>(_onClearMoods);
  }

  void _onAddMood(AddMood event, Emitter<MoodState> emit) {
    final newEntry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: event.type,
      timestamp: DateTime.now(),
    );
    
    // Add to the beginning of the list to show newest first
    final updatedEntries = [newEntry, ...state.entries];
    emit(state.copyWith(entries: updatedEntries));
  }

  void _onClearMoods(ClearMoods event, Emitter<MoodState> emit) {
    emit(const MoodState(entries: []));
  }
}
