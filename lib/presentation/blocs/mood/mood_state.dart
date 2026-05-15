import 'package:equatable/equatable.dart';
import '../../../data/models/mood_entry.dart';

class MoodState extends Equatable {
  final List<MoodEntry> entries;

  const MoodState({this.entries = const []});

  MoodState copyWith({List<MoodEntry>? entries}) {
    return MoodState(
      entries: entries ?? this.entries,
    );
  }

  @override
  List<Object?> get props => [entries];
}
