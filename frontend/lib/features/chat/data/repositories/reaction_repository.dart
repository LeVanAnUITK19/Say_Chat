import '../api/reaction_api.dart';
import '../model/message.dart';

class ReactionRepository {
  final ReactionAPI _reactionAPI = ReactionAPI();

  Future<List<MessageReaction>> addReaction({
    required String messageId,
    required String emoji,
  }) async {
    final response = await _reactionAPI.addReaction(
      messageId: messageId,
      emoji: emoji,
    );
    
    final reactions = response['reactions'] as List<dynamic>;
    return reactions
        .map((json) => MessageReaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<MessageReaction>> removeReaction({
    required String messageId,
  }) async {
    final response = await _reactionAPI.removeReaction(messageId: messageId);
    
    final reactions = response['reactions'] as List<dynamic>;
    return reactions
        .map((json) => MessageReaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<MessageReaction>> getReactions({
    required String messageId,
  }) async {
    final reactions = await _reactionAPI.getReactions(messageId: messageId);
    return reactions
        .map((json) => MessageReaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
