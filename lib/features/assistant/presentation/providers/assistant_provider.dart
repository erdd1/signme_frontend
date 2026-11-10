import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_exception_mapper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/assistant_remote_datasource.dart';
import '../../domain/entities/assistant_message_entity.dart';

final assistantRemoteDataSourceProvider = Provider<AssistantRemoteDataSource>((ref) {
  return AssistantRemoteDataSource(ref.watch(dioProvider));
});

class AssistantChatState {
  const AssistantChatState({
    this.messages = const [],
    this.isSending = false,
    this.error,
  });

  final List<AssistantMessageEntity> messages;

  /// Une question est en attente de réponse (animation d'écriture).
  final bool isSending;

  /// Message d'erreur de la dernière tentative ; la question reste dans
  /// [messages] et peut être renvoyée avec [AssistantChatNotifier.retry].
  final String? error;

  bool get isEmpty => messages.isEmpty;
}

class AssistantChatNotifier extends StateNotifier<AssistantChatState> {
  AssistantChatNotifier(this._remote) : super(const AssistantChatState());

  final AssistantRemoteDataSource _remote;

  /// Identifie la conversation en cours : une réponse qui arrive après
  /// « Nouvelle conversation » est ignorée.
  int _session = 0;

  Future<void> send(String text) async {
    final question = text.trim();
    if (question.isEmpty || state.isSending) return;

    state = AssistantChatState(
      messages: [
        ...state.messages,
        AssistantMessageEntity(role: AssistantRole.user, content: question),
      ],
      isSending: true,
    );
    await _ask();
  }

  /// Renvoie la dernière question après une erreur.
  Future<void> retry() async {
    if (state.isSending || state.error == null || state.isEmpty) return;
    state = AssistantChatState(messages: state.messages, isSending: true);
    await _ask();
  }

  void reset() {
    _session++;
    state = const AssistantChatState();
  }

  Future<void> _ask() async {
    final session = _session;
    try {
      final reply = await _remote.chat(state.messages);
      if (session != _session || !mounted) return;
      state = AssistantChatState(
        messages: [
          ...state.messages,
          AssistantMessageEntity(role: AssistantRole.assistant, content: reply),
        ],
      );
    } catch (e) {
      if (session != _session || !mounted) return;
      state = AssistantChatState(messages: state.messages, error: messageFromError(e));
    }
  }
}

/// autoDispose : la conversation disparaît quand on quitte l'écran
/// (« on ne stocke rien »).
final assistantChatProvider =
    StateNotifierProvider.autoDispose<AssistantChatNotifier, AssistantChatState>(
  (ref) => AssistantChatNotifier(ref.watch(assistantRemoteDataSourceProvider)),
);
