import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/mood_entry.dart';
import '../blocs/mood/mood_bloc.dart';
import '../blocs/mood/mood_event.dart';
import '../blocs/mood/mood_state.dart';
import '../widgets/mood_face_painter.dart';

class MoodTrackerPage extends StatelessWidget {
  const MoodTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade50,
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const Spacer(),
              _buildMoodSelector(context),
              const Spacer(),
              _buildTimelineSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your daily emotional journey',
            style: TextStyle(
              fontSize: 16,
              color: Colors.indigo.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _MoodButton(
            type: MoodType.sad,
            label: 'Sad',
            color: Colors.indigo.shade400,
            onTap: () => context.read<MoodBloc>().add(const AddMood(MoodType.sad)),
          ),
          _MoodButton(
            type: MoodType.neutral,
            label: 'Neutral',
            color: Colors.amber.shade400,
            onTap: () => context.read<MoodBloc>().add(const AddMood(MoodType.neutral)),
          ),
          _MoodButton(
            type: MoodType.happy,
            label: 'Happy',
            color: Colors.teal.shade400,
            onTap: () => context.read<MoodBloc>().add(const AddMood(MoodType.happy)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Moods',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade900,
                ),
              ),
              BlocBuilder<MoodBloc, MoodState>(
                builder: (context, state) {
                  if (state.entries.isEmpty) return const SizedBox.shrink();
                  return TextButton(
                    onPressed: () => context.read<MoodBloc>().add(ClearMoods()),
                    child: const Text('Clear'),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: BlocBuilder<MoodBloc, MoodState>(
            builder: (context, state) {
              if (state.entries.isEmpty) {
                return Center(
                  child: Text(
                    'No entries yet. Tap a mood to start!',
                    style: TextStyle(color: Colors.indigo.shade200),
                  ),
                );
              }

              final recentEntries = state.entries.take(7).toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recentEntries.length,
                itemBuilder: (context, index) {
                  return TimelineEntryItem(entry: recentEntries[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MoodButton extends StatefulWidget {
  final MoodType type;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MoodButton({
    required this.type,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_MoodButton> createState() => _MoodButtonState();
}

class _MoodButtonState extends State<_MoodButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: MoodFace(type: widget.type, size: 60, color: widget.color),
            ),
            const SizedBox(height: 12),
            Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineEntryItem extends StatefulWidget {
  final MoodEntry entry;

  const TimelineEntryItem({super.key, required this.entry});

  @override
  State<TimelineEntryItem> createState() => _TimelineEntryItemState();
}

class _TimelineEntryItemState extends State<TimelineEntryItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getMoodColor(widget.entry.type);
    final dateStr = DateFormat('MMM d').format(widget.entry.timestamp);
    final timeStr = DateFormat('jm').format(widget.entry.timestamp);

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _shakeAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          width: 120,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: color.withOpacity(0.1),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              MoodFace(type: widget.entry.type, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 20,
                height: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMoodColor(MoodType type) {
    switch (type) {
      case MoodType.sad:
        return Colors.indigo.shade400;
      case MoodType.neutral:
        return Colors.amber.shade400;
      case MoodType.happy:
        return Colors.teal.shade400;
    }
  }
}
