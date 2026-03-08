class Medicine {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final List<String> reminderTimes; // HH:mm format
  final bool isActive;
  final String? notes;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.reminderTimes = const [],
    this.isActive = true,
    this.notes,
    required this.startDate,
    this.endDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'reminderTimes': reminderTimes,
        'isActive': isActive,
        'notes': notes,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        dosage: json['dosage'] ?? '',
        frequency: json['frequency'] ?? '',
        reminderTimes: List<String>.from(json['reminderTimes'] ?? []),
        isActive: json['isActive'] ?? true,
        notes: json['notes'],
        startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
        endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}
