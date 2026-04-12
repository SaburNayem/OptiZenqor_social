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

  static const List<Color> textColors = <Color>[
    Colors.white,
    Color(0xFFFFF176),
    Color(0xFF80DEEA),
    Color(0xFFFFAB91),
    Color(0xFFC5E1A5),
  ];

  final StoryPreviewModel preview;
  final TextEditingController textController;
  final FocusNode textFocusNode;

  String _selectedMusic;
  bool _isEditingText = false;
  Color _selectedTextColor = textColors.first;

  String get selectedMusic => _selectedMusic;
  bool get isEditingText => _isEditingText;
  Color get selectedTextColor => _selectedTextColor;
  bool get hasText => textController.text.trim().isNotEmpty;
  String get currentText => textController.text.trim();

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

  void cycleTextColor() {
    final int currentIndex = textColors.indexOf(_selectedTextColor);
    final int safeIndex = currentIndex < 0 ? 0 : currentIndex;
    _selectedTextColor = textColors[(safeIndex + 1) % textColors.length];
    notifyListeners();
  }

  void setTextColor(Color color) {
    _selectedTextColor = color;
    notifyListeners();
  }

  @override
  void dispose() {
    textController.dispose();
    textFocusNode.dispose();
    super.dispose();
  }
}
