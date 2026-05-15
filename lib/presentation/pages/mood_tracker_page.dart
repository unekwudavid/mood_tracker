import 'dart:math' as math;
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
              const Color(0xFF4338CA), // Solid Indigo 700
              const Color(0xFF312E81), // Solid Indigo 800
              const Color(0xFF1E1B4B), // Solid Indigo 900
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'MOOD TRACKER',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildHeader(context),
                    const Spacer(),
                    _buildMoodSelector(context),
                    const Spacer(),
                    _buildTimelineSection(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling?',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Track your daily emotional journey',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w500,
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
            onTap: () =>
                context.read<MoodBloc>().add(const AddMood(MoodType.sad)),
          ),
          _MoodButton(
            type: MoodType.neutral,
            label: 'Neutral',
            color: Colors.amber.shade400,
            onTap: () =>
                context.read<MoodBloc>().add(const AddMood(MoodType.neutral)),
          ),
          _MoodButton(
            type: MoodType.happy,
            label: 'Happy',
            color: Colors.teal.shade400,
            onTap: () =>
                context.read<MoodBloc>().add(const AddMood(MoodType.happy)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context) {
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
                style: Theme.of(context).textTheme.titleLarge,
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

class _MoodButtonState extends State<_MoodButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
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

class _TimelineEntryItemState extends State<TimelineEntryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Happy: jump + spin (uses value 0.0 → 1.0 → 0.0)
  // Neutral: side-to-side shake (uses sin-based oscillation)
  // Sad: slow sink then drag back (uses value 0.0 → 1.0 → 0.0)

  @override
  void initState() {
    super.initState();
    final duration = switch (widget.entry.type) {
      MoodType.happy => const Duration(milliseconds: 600),
      MoodType.neutral => const Duration(milliseconds: 500),
      MoodType.sad => const Duration(milliseconds: 900),
    };
    _controller = AnimationController(vsync: this, duration: duration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() async {
    _controller.value = 0.0;
    await _controller.forward();
    await _controller.reverse();
    _controller.value = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getMoodColor(widget.entry.type);
    final dateStr = DateFormat('MMM d').format(widget.entry.timestamp);
    final timeStr = DateFormat('jm').format(widget.entry.timestamp);

    final cardContent = Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
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
            style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
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
    );

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          switch (widget.entry.type) {
            // ✨ HAPPY: Jumps UP and does a celebratory spin
            case MoodType.happy:
              final jumpValue = Curves.easeOutCubic.transform(
                (_controller.value <= 0.5)
                    ? _controller.value * 2
                    : (1 - _controller.value) * 2,
              );
              final spinValue = _controller.value * 2 * 3.14159;
              return Transform.translate(
                offset: Offset(0, -60 * jumpValue), // jump 60px upward
                child: Transform.rotate(
                  angle: spinValue * 0.2, // gentle spin
                  child: Transform.scale(
                    scale: 1.0 + 0.2 * jumpValue, // grows while jumping
                    child: child,
                  ),
                ),
              );

            // 😐 NEUTRAL: Wobbles side to side (left-right shake)
            case MoodType.neutral:
              final shakeValue = math.sin(_controller.value * math.pi * 4);
              return Transform.translate(
                offset: Offset(shakeValue * 12, 0), // 12px side shake
                child: Transform.rotate(
                  angle: shakeValue * 0.08, // slight tilt while shaking
                  child: child,
                ),
              );

            // 😔 SAD: Slowly droops down then sluggishly returns
            case MoodType.sad:
              final sinkValue = Curves.easeIn.transform(
                (_controller.value <= 0.6)
                    ? _controller.value / 0.6
                    : (1 - _controller.value) / 0.4,
              );
              return Transform.translate(
                offset: Offset(0, 30 * sinkValue), // sink 30px downward
                child: Transform.scale(
                  scale: 1.0 - 0.15 * sinkValue, // shrinks as it sinks
                  child: Opacity(
                    opacity: 1.0 - 0.3 * sinkValue, // fades slightly
                    child: child,
                  ),
                ),
              );
          }
        },
        child: cardContent,
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
