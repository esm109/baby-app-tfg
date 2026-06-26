class BabyDevelopment {
  final int id;
  final int stageId;
  final String title;
  final String description;
  final String weekReference;
  final int orderIndex;

  BabyDevelopment({
    required this.id,
    required this.stageId,
    required this.title,
    required this.description,
    required this.weekReference,
    required this.orderIndex,
  });

  factory BabyDevelopment.fromJson(Map<String, dynamic> json) {
    return BabyDevelopment(
      id: json['id'],
      stageId: json['stage_id'],
      title: json['title'],
      description: json['description'],
      weekReference: json['week_reference'],
      orderIndex: json['order_index'],
    );
  }
}