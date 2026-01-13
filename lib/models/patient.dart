class Patient {
  final String id;
  final String name;
  final String? phone;
  final bool isSocial;

  Patient({
    required this.id,
    required this.name,
    this.phone,
    this.isSocial = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, 
      'name': name, 
      'phone': phone, 
      'isSocial': isSocial
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      isSocial: map['isSocial'] ?? false,
    );
  }
}
