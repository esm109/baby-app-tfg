class Tip {
  final int id;
  final String title;
  final String content;
  final int categoryId;
  final int? stageId;

  Tip({
    required this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    this.stageId,
  });

  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      categoryId: json['category_id'],
      stageId: json['stage_id'],
    );
  }
}