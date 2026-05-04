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

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'is_social': isSocial ? 1 : 0,
    'social_value': socialValue,
  };

  factory Patient.fromMap(Map<String, dynamic> map) => Patient(
    id: map['id'] as String,
    name: map['name'] as String,
    phone: map['phone'] as String?,
    isSocial: (map['is_social'] as int? ?? 0) == 1,
    socialValue: map['social_value'] as double?,
  );
}
