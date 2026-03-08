class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String? relationship;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.relationship,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'relationship': relationship,
      };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        relationship: json['relationship'],
      );
}
