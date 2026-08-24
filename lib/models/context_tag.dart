import 'package:flutter/material.dart';

enum ContextTag {
  beforeMeal,
  afterMeal,
  fasting,
  exercise,
  stress,
  sickDay,
  bedtime,
  insulinSkipped,
  calorieFocus,
}

extension ContextTagX on ContextTag {
  String get label => switch (this) {
        ContextTag.beforeMeal => 'Before meal',
        ContextTag.afterMeal => 'After meal',
        ContextTag.fasting => 'Fasting',
        ContextTag.exercise => 'Exercise',
        ContextTag.stress => 'Stress',
        ContextTag.sickDay => 'Sick day',
        ContextTag.bedtime => 'Bedtime',
        ContextTag.insulinSkipped => 'Insulin skipped',
        ContextTag.calorieFocus => 'Calorie focus',
      };

  IconData get icon => switch (this) {
        ContextTag.beforeMeal => Icons.restaurant_outlined,
        ContextTag.afterMeal => Icons.lunch_dining_outlined,
        ContextTag.fasting => Icons.timer_outlined,
        ContextTag.exercise => Icons.directions_run_outlined,
        ContextTag.stress => Icons.psychology_outlined,
        ContextTag.sickDay => Icons.sick_outlined,
        ContextTag.bedtime => Icons.bedtime_outlined,
        ContextTag.insulinSkipped => Icons.medication_outlined,
        ContextTag.calorieFocus => Icons.calculate_outlined,
      };
}
