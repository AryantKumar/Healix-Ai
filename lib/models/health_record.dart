class HealthRecord {
  final String id;
  final String title;
  final String category; // Prescription, Lab Report, X-Ray, Medical Note, etc.
  final String? notes;
  final String? filePath;
  final DateTime date;
  final DateTime createdAt;

  HealthRecord({
    required this.id,
    required this.title,
    required this.category,
    this.notes,
    this.filePath,
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'notes': notes,
        'filePath': filePath,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory HealthRecord.fromJson(Map<String, dynamic> json) => HealthRecord(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        category: json['category'] ?? 'Other',
        notes: json['notes'],
        filePath: json['filePath'],
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}
