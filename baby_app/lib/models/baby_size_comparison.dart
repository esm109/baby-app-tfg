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
      id: json['id'] ?? 0,
      weekNumber: json['week_number'] ?? 0,
      comparisonType: json['comparison_type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      sizeText: json['size_text']?.toString() ?? json['title']?.toString() ?? '',
      orderIndex: json['order_index'] ?? 0,
    );
  }
}