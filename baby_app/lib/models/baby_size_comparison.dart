class BabySizeComparison {
  final int id;
  final int weekNumber;
  final String comparisonType;
  final String title;
  final String emoji;
  final String description;
  final String sizeText;
  final int orderIndex;

  BabySizeComparison({
    required this.id,
    required this.weekNumber,
    required this.comparisonType,
    required this.title,
    required this.emoji,
    required this.description,
    required this.sizeText,
    required this.orderIndex,
  });

  factory BabySizeComparison.fromJson(Map<String, dynamic> json) {
    return BabySizeComparison(
      id: json['id'],
      weekNumber: json['week_number'],
      comparisonType: json['comparison_type'],
      title: json['title'],
      emoji: json['emoji'],
      description: json['description'],
      sizeText: json['size_text'],
      orderIndex: json['order_index'],
    );
  }
}