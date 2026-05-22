class WeeklyTip {
  final int id;
  final int weekNumber;
  final String title;
  final String description;
  final String category;
  final String priority;
  final int orderIndex;

  WeeklyTip({
    required this.id,
    required this.weekNumber,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.orderIndex,
  });

  factory WeeklyTip.fromJson(Map<String, dynamic> json) {
    return WeeklyTip(
      id: json['id'],
      weekNumber: json['week_number'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      priority: json['priority'],
      orderIndex: json['order_index'],
    );
  }
}