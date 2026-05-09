import '../../../core/data/api/api_payload_reader.dart';

class SupportTicketSummaryModel {
  const SupportTicketSummaryModel({
    required this.id,
    required this.subject,
    required this.category,
    required this.status,
    required this.priority,
    required this.latestMessage,
    required this.updatedAt,
  });

  final String id;
  final String subject;
  final String category;
  final String status;
  final String priority;
  final String latestMessage;
  final String updatedAt;

  SupportTicketSummaryModel copyWith({
    String? id,
    String? subject,
    String? category,
    String? status,
    String? priority,
    String? latestMessage,
    String? updatedAt,
  }) {
    return SupportTicketSummaryModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      latestMessage: latestMessage ?? this.latestMessage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory SupportTicketSummaryModel.fromApiJson(Map<String, dynamic> json) {
    return SupportTicketSummaryModel(
      id: ApiPayloadReader.readString(json['id']),
      subject: ApiPayloadReader.readString(json['subject']),
      category: ApiPayloadReader.readString(json['category']),
      status: ApiPayloadReader.readString(json['status']),
      priority: ApiPayloadReader.readString(json['priority']),
      latestMessage: ApiPayloadReader.readString(json['latestMessage']),
      updatedAt: ApiPayloadReader.readString(json['updatedAt']),
    );
  }
}
