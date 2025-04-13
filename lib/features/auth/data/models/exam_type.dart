class ExamType {
  final int id;
  final String name;
  final String description;
  final String? image;
  final double price;

  const ExamType({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    required this.price,
  });

  factory ExamType.fromJson(Map<String, dynamic> json) {
    return ExamType(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['decription'] as String,
      image: json['image'] as String?,
      price: double.tryParse(json['price']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
    };
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamType &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
} 