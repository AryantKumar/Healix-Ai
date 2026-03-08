class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isOffline;
  final bool isDisclaimer;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isOffline = false,
    this.isDisclaimer = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'isOffline': isOffline,
        'isDisclaimer': isDisclaimer,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] ?? '',
        text: json['text'] ?? '',
        isUser: json['isUser'] ?? false,
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        isOffline: json['isOffline'] ?? false,
        isDisclaimer: json['isDisclaimer'] ?? false,
      );
}
