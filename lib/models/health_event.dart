enum HealthEventType { symptom, prescription, visit, record, medicine }

class HealthEvent {
  final String id;
  final String title;
  final String? description;
  final HealthEventType type;
  final DateTime date;
  final Map<String, dynamic>? metadata;

  HealthEvent({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.date,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'date': date.toIso8601String(),
        'metadata': metadata,
      };

  factory HealthEvent.fromJson(Map<String, dynamic> json) => HealthEvent(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'],
        type: HealthEventType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => HealthEventType.symptom,
        ),
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        metadata: json['metadata'] != null
            ? Map<String, dynamic>.from(json['metadata'])
            : null,
      );
}
