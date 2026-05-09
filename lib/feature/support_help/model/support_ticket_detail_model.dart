import '../../../core/data/api/api_payload_reader.dart';
import 'support_ticket_message_model.dart';
import 'support_ticket_summary_model.dart';

class SupportTicketDetailModel {
  const SupportTicketDetailModel({
    required this.summary,
    required this.conversationId,
    required this.conversationStatus,
    required this.channel,
    required this.userLabel,
    required this.adminNotes,
    required this.assignedAdminId,
    required this.slaHours,
    required this.slaDueAt,
    required this.messages,
  });

  final SupportTicketSummaryModel summary;
  final String conversationId;
  final String conversationStatus;
  final String channel;
  final String userLabel;
  final List<String> adminNotes;
  final String assignedAdminId;
  final int? slaHours;
  final String slaDueAt;
  final List<SupportTicketMessageModel> messages;

  factory SupportTicketDetailModel.fromApiJson(Map<String, dynamic> json) {
    return SupportTicketDetailModel(
      summary: SupportTicketSummaryModel.fromApiJson(json),
      conversationId: ApiPayloadReader.readString(json['conversationId']),
      conversationStatus: ApiPayloadReader.readString(
        json['conversationStatus'],
      ),
      channel: ApiPayloadReader.readString(json['channel']),
      userLabel: ApiPayloadReader.readString(json['userLabel']),
      adminNotes: ApiPayloadReader.readStringList(json['adminNotes']),
      assignedAdminId: ApiPayloadReader.readString(json['assignedAdminId']),
      slaHours: _readNullableInt(json['slaHours']),
      slaDueAt: ApiPayloadReader.readString(json['slaDueAt']),
      messages: ApiPayloadReader.readMapListFromAny(
        json['messages'],
        preferredKeys: const <String>['messages'],
      ).map(SupportTicketMessageModel.fromApiJson).toList(growable: false),
    );
  }

  SupportTicketDetailModel copyWith({
    SupportTicketSummaryModel? summary,
    String? conversationId,
    String? conversationStatus,
    String? channel,
    String? userLabel,
    List<String>? adminNotes,
    String? assignedAdminId,
    int? slaHours,
    bool clearSlaHours = false,
    String? slaDueAt,
    List<SupportTicketMessageModel>? messages,
  }) {
    return SupportTicketDetailModel(
      summary: summary ?? this.summary,
      conversationId: conversationId ?? this.conversationId,
      conversationStatus: conversationStatus ?? this.conversationStatus,
      channel: channel ?? this.channel,
      userLabel: userLabel ?? this.userLabel,
      adminNotes: adminNotes ?? this.adminNotes,
      assignedAdminId: assignedAdminId ?? this.assignedAdminId,
      slaHours: clearSlaHours ? null : (slaHours ?? this.slaHours),
      slaDueAt: slaDueAt ?? this.slaDueAt,
      messages: messages ?? this.messages,
    );
  }

  static int? _readNullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    final int resolved = ApiPayloadReader.readInt(value);
    return resolved <= 0 ? null : resolved;
  }
}
