class UserProfile {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String bloodGroup;
  final double height; // cm
  final double weight; // kg
  final List<String> allergies;
  final List<String> chronicConditions;
  final bool isForSelf;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.height,
    required this.weight,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.isForSelf = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'gender': gender,
        'bloodGroup': bloodGroup,
        'height': height,
        'weight': weight,
        'allergies': allergies,
        'chronicConditions': chronicConditions,
        'isForSelf': isForSelf,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        age: json['age'] ?? 0,
        gender: json['gender'] ?? '',
        bloodGroup: json['bloodGroup'] ?? '',
        height: (json['height'] ?? 0).toDouble(),
        weight: (json['weight'] ?? 0).toDouble(),
        allergies: List<String>.from(json['allergies'] ?? []),
        chronicConditions: List<String>.from(json['chronicConditions'] ?? []),
        isForSelf: json['isForSelf'] ?? true,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}
