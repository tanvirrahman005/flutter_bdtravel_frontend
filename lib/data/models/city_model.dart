class CityModel {
  final int id;
  final String name;
  final String? bnName;
  final String? code;
  final bool isActive;

  CityModel({
    required this.id,
    required this.name,
    this.bnName,
    this.code,
    this.isActive = true,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'],
      name: json['name'] ?? '',
      bnName: json['bnName'],
      code: json['code'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bnName': bnName,
      'code': code,
      'isActive': isActive,
    };
  }
}
