class TransportCompanyModel {
  final int id;
  final String name;
  final String? code;
  final String? contactNumber;
  final String? email;
  final String? address;
  final String? logoUrl;
  final bool isActive;

  TransportCompanyModel({
    required this.id,
    required this.name,
    this.code,
    this.contactNumber,
    this.email,
    this.address,
    this.logoUrl,
    this.isActive = true,
  });

  factory TransportCompanyModel.fromJson(Map<String, dynamic> json) {
    return TransportCompanyModel(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'],
      contactNumber: json['contactNumber'],
      email: json['email'],
      address: json['address'],
      logoUrl: json['logoUrl'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'contactNumber': contactNumber,
      'email': email,
      'address': address,
      'logoUrl': logoUrl,
      'isActive': isActive,
    };
  }
}
