class Stage {
  final int id;
  final String name;
  final int startWeek;
  final int endWeek;
  final String shortDescription;
  final String keyPoints;
  final String? mediaType;
  final String? mediaUrl;
  final int orderIndex;

  Stage({
    required this.id,
    required this.name,
    required this.startWeek,
    required this.endWeek,
    required this.shortDescription,
    required this.keyPoints,
    this.mediaType,
    this.mediaUrl,
    required this.orderIndex,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['id'],
      name: json['name'],
      startWeek: json['start_week'],
      endWeek: json['end_week'],
      shortDescription: json['short_description'],
      keyPoints: json['key_points'],
      mediaType: json['media_type'],
      mediaUrl: json['media_url'],
      orderIndex: json['order_index'],
    );
  }
}