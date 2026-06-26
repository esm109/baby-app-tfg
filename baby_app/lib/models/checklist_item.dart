class ChecklistItem {
  final int id;
  final String task;
  final String category;

  ChecklistItem({
    required this.id,
    required this.task,
    required this.category,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'],
      task: json['task'],
      category: json['category'] ?? '',
    );
  }
}