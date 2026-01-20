class Patient {
  final String id;
  final String name;
  final String? phone;
  final bool isSocial;
  final double? socialValue;

  Patient({
    required this.id,
    required this.name,
    this.phone,
    this.isSocial = false,
    this.socialValue,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'phone': phone, 'isSocial': isSocial, 'socialValur': socialValue};
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      isSocial: map['isSocial'] ?? false,
      socialValue: map['socialValue'] is double ? map['socialValue'] : null,
    );
  }
}
