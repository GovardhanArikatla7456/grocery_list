class GroceryItem {
  final String id;
  final String name;

  GroceryItem({required this.id, required this.name});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'],
      name: json['name'],
    );
  }
}