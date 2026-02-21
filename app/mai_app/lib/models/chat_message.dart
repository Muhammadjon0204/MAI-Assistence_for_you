class ChatMessage {
  final String id;
  String text;
  final bool isUser;
  final dynamic timestamp;
  final bool isFromOCR;

  ChatMessage({
    String? id,
    required this.text,
    required this.isUser,
    dynamic timestamp,
    this.isFromOCR = false,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  DateTime get dateTime {
    if (timestamp is DateTime) return timestamp;
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }
}
