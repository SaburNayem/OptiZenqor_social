import '../../../core/data/api/api_payload_reader.dart';

class SupportTicketMessageModel {
  const SupportTicketMessageModel({
    required this.id,
    required this.senderType,
    required this.senderLabel,
    required this.body,
    required this.attachments,
    required this.createdAt,
  });

  final String id;
  final String senderType;
  final String senderLabel;
  final String body;
  final List<String> attachments;
  final String createdAt;

  bool get isFromSupport => senderType.trim().toLowerCase() == 'agent';

  factory SupportTicketMessageModel.fromApiJson(Map<String, dynamic> json) {
    return SupportTicketMessageModel(
      id: ApiPayloadReader.readString(json['id']),
      senderType: ApiPayloadReader.readString(json['senderType']),
      senderLabel: ApiPayloadReader.readString(
        json['senderLabel'],
        fallback: ApiPayloadReader.readString(
          json['sender'],
          fallback: 'Support',
        ),
      ),
      body: ApiPayloadReader.readString(
        json['body'],
        fallback: ApiPayloadReader.readString(json['text']),
      ),
      attachments: ApiPayloadReader.readStringList(json['attachments']),
      createdAt: ApiPayloadReader.readString(json['createdAt']),
    );
  }
}
