class MarketplaceChatMessage {
  const MarketplaceChatMessage({
    required this.id,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.senderId,
    this.productId,
    this.imageUrl,
    this.isOffer = false,
    this.offerAmount,
    this.productTitle,
  });

  final String id;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final String? senderId;
  final String? productId;
  final String? imageUrl;
  final bool isOffer;
  final double? offerAmount;
  final String? productTitle;
}

class MarketplaceOfferEvent {
  const MarketplaceOfferEvent({
    required this.actor,
    required this.action,
    required this.amount,
    required this.timestamp,
    this.id,
    this.productId,
    this.status,
    this.note,
  });

  final String? id;
  final String? productId;
  final String actor;
  final String action;
  final double amount;
  final DateTime timestamp;
  final String? status;
  final String? note;
}
