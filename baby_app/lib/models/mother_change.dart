class MotherChange {
  final int id;
  final int stageId;
  final String symptom;
  final String description;
  final String type;
  final int orderIndex;

  MotherChange({
    required this.id,
    required this.stageId,
    required this.symptom,
    required this.description,
    required this.type,
    required this.orderIndex,
  });

  factory MotherChange.fromJson(Map<String, dynamic> json) {
    return MotherChange(
      id: json['id'],
      stageId: json['stage_id'],
      symptom: json['symptom'],
      description: json['description'],
      type: json['type'],
      orderIndex: json['order_index'],
    );
  }
}