import 'app_logger.dart';

class AppId {
  AppId._();

  static final RegExp _pattern = RegExp(
    r'^(user|post|story|reel|upload|media|comment|reaction|share|bookmark|collection|notification|thread|message|event|community|group|page|job|application|product|order|wallet|wallet_tx|subscription|verification|report|session|support|draft)_[a-f0-9]{32}$',
  );

  static bool isValid(String value) => _pattern.hasMatch(value.trim());

  static bool isUserId(String value) =>
      value.trim().startsWith('user_') && isValid(value);

  static bool isPostId(String value) =>
      value.trim().startsWith('post_') && isValid(value);

  static bool isStoryId(String value) =>
      value.trim().startsWith('story_') && isValid(value);

  static bool isUploadId(String value) =>
      value.trim().startsWith('upload_') && isValid(value);

  static String makeLocal(String entity, {int sequence = 0}) {
    return '${entity}_local_${DateTime.now().microsecondsSinceEpoch}_$sequence';
  }

  static void warnIfNotProductionId(String value, {required String entity}) {
    final String normalized = value.trim();
    if (normalized.isEmpty ||
        isValid(normalized) ||
        normalized.startsWith('local_') ||
        normalized.contains('_local_')) {
      return;
    }
    AppLogger.info('[ID MIGRATION] Non-production $entity id: $normalized');
  }
}
