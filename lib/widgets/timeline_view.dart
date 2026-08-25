import 'package:flutter/material.dart';
import '../models/time_block.dart';

class TimelineView extends StatelessWidget {
  final DateTime date;
  final List<TimeBlock> blocks;
  final ValueChanged<TimeBlock> onTap;
  final VoidCallback onAdd;

  const TimelineView({
    super.key,
    required this.date,
    required this.blocks,
    required this.onTap,
    required this.onAdd,
  });

  static const double hourHeight = 64;
  static const double labelWidth = 52;

  bool get _isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _formatHour(int h) {
    if (h == 0) return '12 AM';
    if (h == 12) return '12 PM';
    return h < 12 ? '$h AM' : '${h - 12} PM';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nowFraction = now.hour + now.minute / 60.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 90),
      child: SizedBox(
        height: hourHeight * 24,
        child: Stack(
          children: [
            for (int h = 0; h < 24; h++)
              Positioned(
                top: h * hourHeight,
                left: 0,
                right: 0,
                child: Container(
                  height: hourHeight,
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade200))),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: SizedBox(
                      width: labelWidth,
                      child: Text(_formatHour(h), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ),
                  ),
                ),
              ),
            if (blocks.isEmpty)
              Positioned(
                top: 8 * hourHeight,
                left: labelWidth + 16,
                right: 16,
                child: GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'No time blocks yet — tap to add one',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            for (final b in blocks)
              Positioned(
                top: b.startFraction * hourHeight,
                left: labelWidth + 8,
                right: 8,
                height: (b.endFraction - b.startFraction).clamp(0.25, 24) * hourHeight,
                child: GestureDetector(
                  onTap: () => onTap(b),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: b.category.color.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          b.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${b.startTime.format(context)} \u2013 ${b.endTime.format(context)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_isToday)
              Positioned(
                top: nowFraction * hourHeight,
                left: labelWidth,
                right: 0,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                    Expanded(child: Container(height: 1.5, color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
