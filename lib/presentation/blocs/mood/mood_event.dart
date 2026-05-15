import 'package:equatable/equatable.dart';
import '../../../data/models/mood_entry.dart';

abstract class MoodEvent extends Equatable {
  const MoodEvent();

  @override
  List<Object?> get props => [];
}

class AddMood extends MoodEvent {
  final MoodType type;
  const AddMood(this.type);

  @override
  List<Object?> get props => [type];
}

class ClearMoods extends MoodEvent {}
