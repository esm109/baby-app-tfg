class PregnancyCalculator {
  static int calculateWeekFromDueDate(DateTime dueDate) {
    final today = DateTime.now();

    final pregnancyStart = dueDate.subtract(
      const Duration(days: 280),
    );

    final daysPregnant = today.difference(pregnancyStart).inDays;

    final week = (daysPregnant / 7).floor() + 1;

    if (week < 1) return 1;
    if (week > 40) return 40;

    return week;
  }

  static int calculateDaysRemaining(DateTime dueDate) {
    final today = DateTime.now();

    final remaining = dueDate.difference(today).inDays;

    return remaining < 0 ? 0 : remaining;
  }

  static int calculateTrimester(int week) {
    if (week <= 12) return 1;
    if (week <= 28) return 2;
    return 3;
  }
}