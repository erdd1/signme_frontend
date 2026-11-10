import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signme/core/errors/exceptions.dart';
import 'package:signme/features/assistant/data/datasources/assistant_remote_datasource.dart';
import 'package:signme/features/assistant/domain/entities/assistant_message_entity.dart';
import 'package:signme/features/assistant/presentation/providers/assistant_provider.dart';

/// Ne touche jamais au réseau : chaque question est mise en attente et
/// résolue manuellement par le test.
class _FakeAssistantRemoteDataSource extends AssistantRemoteDataSource {
  _FakeAssistantRemoteDataSource() : super(Dio());

  final List<List<AssistantMessageEntity>> conversations = [];
  final List<Completer<String>> pending = [];

  @override
  Future<String> chat(List<AssistantMessageEntity> conversation) {
    conversations.add(List.of(conversation));
    final completer = Completer<String>();
    pending.add(completer);
    return completer.future;
  }
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _FakeAssistantRemoteDataSource remote;
  late AssistantChatNotifier notifier;

  setUp(() {
    remote = _FakeAssistantRemoteDataSource();
    notifier = AssistantChatNotifier(remote);
  });

  tearDown(() => notifier.dispose());

  test('la question apparaît tout de suite, puis la réponse s\'ajoute', () async {
    final future = notifier.send('  Que dit la Bible sur le pardon ?  ');

    expect(notifier.state.isSending, isTrue);
    expect(notifier.state.messages.single.content, 'Que dit la Bible sur le pardon ?');
    expect(notifier.state.messages.single.isUser, isTrue);

    remote.pending.single.complete('Éphésiens 4:32');
    await future;

    expect(notifier.state.isSending, isFalse);
    expect(notifier.state.messages.map((m) => m.isUser), [true, false]);
    expect(notifier.state.messages.last.content, 'Éphésiens 4:32');
  });

  test('une question vide est ignorée', () async {
    await notifier.send('   ');

    expect(notifier.state.isEmpty, isTrue);
    expect(remote.conversations, isEmpty);
  });

  test('pas de second envoi pendant qu\'une réponse est attendue', () async {
    final first = notifier.send('première');
    await notifier.send('seconde');

    expect(remote.conversations, hasLength(1));
    expect(notifier.state.messages, hasLength(1));

    remote.pending.single.complete('ok');
    await first;
  });

  test('toute la conversation est renvoyée à chaque question', () async {
    final first = notifier.send('première');
    remote.pending[0].complete('réponse 1');
    await first;

    final second = notifier.send('seconde');
    remote.pending[1].complete('réponse 2');
    await second;

    expect(remote.conversations[1].map((m) => m.content), ['première', 'réponse 1', 'seconde']);
  });

  test('une erreur garde la question ; « Réessayer » la renvoie sans la dupliquer', () async {
    final future = notifier.send('question');
    remote.pending[0].completeError(RateLimitException(message: 'Limite atteinte'));
    await future;

    expect(notifier.state.error, 'Limite atteinte');
    expect(notifier.state.isSending, isFalse);
    expect(notifier.state.messages, hasLength(1));

    final retry = notifier.retry();
    expect(notifier.state.isSending, isTrue);
    expect(notifier.state.error, isNull);
    remote.pending[1].complete('enfin');
    await retry;

    expect(notifier.state.messages.map((m) => m.content), ['question', 'enfin']);
    expect(remote.conversations[1], hasLength(1));
  });

  test('« Réessayer » sans erreur ne fait rien', () async {
    await notifier.retry();

    expect(remote.conversations, isEmpty);
  });

  test('une réponse qui arrive après « Nouvelle conversation » est ignorée', () async {
    final future = notifier.send('ancienne question');
    notifier.reset();
    expect(notifier.state.isEmpty, isTrue);

    remote.pending.single.complete('réponse tardive');
    await future;
    await _settle();

    expect(notifier.state.isEmpty, isTrue);
    expect(notifier.state.isSending, isFalse);
  });

  test('une erreur tardive après « Nouvelle conversation » est ignorée', () async {
    final future = notifier.send('ancienne question');
    notifier.reset();

    remote.pending.single.completeError(Exception('boom'));
    await future;

    expect(notifier.state.error, isNull);
    expect(notifier.state.isEmpty, isTrue);
  });

  test('AssistantMessageEntity.toJson envoie les rôles attendus par l\'API', () {
    expect(
      const AssistantMessageEntity(role: AssistantRole.user, content: 'a').toJson(),
      {'role': 'user', 'content': 'a'},
    );
    expect(
      const AssistantMessageEntity(role: AssistantRole.assistant, content: 'b').toJson(),
      {'role': 'assistant', 'content': 'b'},
    );
  });
}
