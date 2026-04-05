import 'package:flutter/material.dart';

import '../model/story_text_composer_model.dart';

class StoryTextComposerController extends ChangeNotifier {
  StoryTextComposerController(this.config)
    : textController = TextEditingController(),
      textFocusNode = FocusNode(),
      _selectedMusic = config.initialMusic;

  static const List<String> musicOptions = <String>[
    'Late Night Drive',
    'Summer Echo',
    'Neon Memory',
    'Soft Horizon',
  ];

  static const List<List<int>> gradients = <List<int>>[
    <int>[0xFF1E40AF, 0xFF2BB0A1],
    <int>[0xFF0F766E, 0xFF34D399],
    <int>[0xFFF59E0B, 0xFFF97316],
  ];

  static const List<Color> textColors = <Color>[
    Colors.white,
    Color(0xFFFFF176),
    Color(0xFF80DEEA),
    Color(0xFFFFAB91),
    Color(0xFFC5E1A5),
  ];

  final StoryTextComposerModel config;
  final TextEditingController textController;
  final FocusNode textFocusNode;

  String _selectedMusic;
  int _gradientIndex = 0;
  int _textColorIndex = 0;

  String get selectedMusic => _selectedMusic;
  int get gradientIndex => _gradientIndex;
  Color get selectedTextColor => textColors[_textColorIndex];
  bool get hasText => textController.text.trim().isNotEmpty;
  bool get showMusic => config.startWithMusic || _selectedMusic.isNotEmpty;
  String get currentText => textController.text.trim();

  void cycleBackground() {
    _gradientIndex = (_gradientIndex + 1) % gradients.length;
    notifyListeners();
  }

  void cycleMusic() {
    final int currentIndex = musicOptions.indexOf(_selectedMusic);
    _selectedMusic = musicOptions[(currentIndex + 1) % musicOptions.length];
    notifyListeners();
  }

  void setMusic(String music) {
    _selectedMusic = music;
    notifyListeners();
  }

  void cycleTextColor() {
    _textColorIndex = (_textColorIndex + 1) % textColors.length;
    notifyListeners();
  }

  void onTextChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    textController.dispose();
    textFocusNode.dispose();
    super.dispose();
  }
}
