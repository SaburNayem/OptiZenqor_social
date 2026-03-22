import 'package:flutter/foundation.dart';

import '../../../core/common_data/mock_data.dart';
import '../../../core/common_models/message_model.dart';

class ChatController extends ChangeNotifier {
  List<MessageModel> messages = <MessageModel>[];

  Future<void> loadChats() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    messages = MockData.messages;
    notifyListeners();
  }
}
