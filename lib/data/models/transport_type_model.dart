class TransportTypeModel {
  final int id;
  final String name;
  final String? description;

  TransportTypeModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory TransportTypeModel.fromJson(Map<String, dynamic> json) {
    return TransportTypeModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
