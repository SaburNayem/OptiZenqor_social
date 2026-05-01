import '../../../core/data/api/api_payload_reader.dart';
import '../../../core/data/models/user_model.dart';

class BuddyRelationshipModel {
  const BuddyRelationshipModel({
    required this.id,
    required this.status,
    required this.mutualCount,
    required this.createdAt,
    required this.user,
  });

  final String id;
  final String status;
  final int mutualCount;
  final DateTime? createdAt;
  final UserModel user;

  factory BuddyRelationshipModel.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? userPayload = ApiPayloadReader.readMap(
      json['user'] ?? json['profile'] ?? json['buddy'] ?? json['target'],
    );
    return BuddyRelationshipModel(
      id: ApiPayloadReader.readString(json['id'] ?? json['_id']),
      status: ApiPayloadReader.readString(json['status'], fallback: 'accepted'),
      mutualCount: ApiPayloadReader.readInt(
        json['mutualCount'] ?? json['mutuals'],
      ),
      createdAt: ApiPayloadReader.readDateTime(
        json['createdAt'] ?? json['updatedAt'],
      ),
      user: UserModel.fromApiJson(userPayload ?? const <String, dynamic>{}),
    );
  }
}
