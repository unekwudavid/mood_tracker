import 'package:equatable/equatable.dart';

enum MoodType { sad, neutral, happy }

class MoodEntry extends Equatable {
  final String id;
  final MoodType type;
  final DateTime timestamp;

  const MoodEntry({
    required this.id,
    required this.type,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, type, timestamp];
}
