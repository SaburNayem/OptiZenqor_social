enum ChatInboxFilter {
  all,
  unread,
  requests,
}

class ChatInboxFilterModel {
  const ChatInboxFilterModel({required this.filter});

  final ChatInboxFilter filter;

  String label() {
    switch (filter) {
      case ChatInboxFilter.all:
        return 'All';
      case ChatInboxFilter.unread:
        return 'Unread';
      case ChatInboxFilter.requests:
        return 'Requests';
    }
  }
}
