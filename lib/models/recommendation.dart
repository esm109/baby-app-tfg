class Recommendation {
  final int id;
  final int stageId;
  final String recommendation;
  final String category;
  final String priority;
  final int orderIndex;

  Recommendation({
    required this.id,
    required this.stageId,
    required this.recommendation,
    required this.category,
    required this.priority,
    required this.orderIndex,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'],
      stageId: json['stage_id'],
      recommendation: json['recommendation'],
      category: json['category'],
      priority: json['priority'],
      orderIndex: json['order_index'],
    );
  }
}