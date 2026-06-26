class HospitalBagItem {
  final int id;
  final String itemName;
  final String category;

  HospitalBagItem({
    required this.id,
    required this.itemName,
    required this.category,
  });

  factory HospitalBagItem.fromJson(Map<String, dynamic> json) {
    return HospitalBagItem(
      id: json['id'],
      itemName: json['item_name'],
      category: json['category'] ?? '',
    );
  }
}