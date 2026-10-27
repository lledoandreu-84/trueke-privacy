class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final bool isDelivered;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.isRead = true,
    this.isDelivered = true,
  });

  String get message => content;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: (json['content'] ?? json['message']) as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? true,
      isDelivered: json['is_delivered'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'conversation_id': conversationId,
        'sender_id': senderId,
        'content': content,
        'is_read': isRead,
        'is_delivered': isDelivered,
      };
}

typedef Message = ChatMessage;
