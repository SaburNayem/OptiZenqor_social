import 'package:flutter/material.dart';

import '../model/story_preview_model.dart';

class StoryPreviewController extends ChangeNotifier {
  StoryPreviewController(this.preview)
      : textController = TextEditingController(text: preview.initialText),
        textFocusNode = FocusNode(),
        _selectedMusic = preview.initialMusic;

  static const List<String> musicOptions = <String>[
    'Late Night Drive',
    'Summer Echo',
    'Neon Memory',
    'Soft Horizon',
  ];

  final StoryPreviewModel preview;
  final TextEditingController textController;
  final FocusNode textFocusNode;

  String _selectedMusic;
  bool _isEditingText = false;

  String get selectedMusic => _selectedMusic;
  bool get isEditingText => _isEditingText;
  bool get hasText => textController.text.trim().isNotEmpty;

  void startTextEditing() {
    _isEditingText = true;
    notifyListeners();
  }

  void stopTextEditing() {
    _isEditingText = false;
    textFocusNode.unfocus();
    notifyListeners();
  }

  void onTextChanged() {
    notifyListeners();
  }

  void setMusic(String music) {
    _selectedMusic = music;
    notifyListeners();
  }

  @override
  void dispose() {
    textController.dispose();
    textFocusNode.dispose();
    super.dispose();
  }
}
