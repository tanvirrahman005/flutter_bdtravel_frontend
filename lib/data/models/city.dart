class City {
  final int id;
  final String name;
  final String code;

  City({
    required this.id,
    required this.name,
    required this.code,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
    );
  }
}
