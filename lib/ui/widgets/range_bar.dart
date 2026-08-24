import 'package:flutter/material.dart';

import '../../theme.dart';

class RangeBar extends StatelessWidget {
  const RangeBar({
    super.key,
    required this.below,
    required this.inRange,
    required this.above,
    this.height = 14,
  });

  final double below;
  final double inRange;
  final double above;
  final double height;

  @override
  Widget build(BuildContext context) {
    final total = below + inRange + above;
    if (total <= 0) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(7),
        ),
      );
    }
    int flexOf(double v) => (v / total * 1000).round();
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            if (below > 0)
              Expanded(flex: flexOf(below), child: ColoredBox(color: kUrgentColor, child: const SizedBox.expand())),
            if (inRange > 0)
              Expanded(flex: flexOf(inRange), child: ColoredBox(color: kInRangeColor, child: const SizedBox.expand())),
            if (above > 0)
              Expanded(flex: flexOf(above), child: ColoredBox(color: kAboveColor, child: const SizedBox.expand())),
          ],
        ),
      ),
    );
  }
}
