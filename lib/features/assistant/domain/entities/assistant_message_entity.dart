enum AssistantRole { user, assistant }

/// Message d'une conversation avec l'assistant. L'historique ne vit qu'en
/// mémoire : il est renvoyé au serveur à chaque question et disparaît quand
/// on quitte l'écran.
class AssistantMessageEntity {
  const AssistantMessageEntity({required this.role, required this.content});

  final AssistantRole role;
  final String content;

  bool get isUser => role == AssistantRole.user;

  Map<String, String> toJson() => {
        'role': isUser ? 'user' : 'assistant',
        'content': content,
      };
}
