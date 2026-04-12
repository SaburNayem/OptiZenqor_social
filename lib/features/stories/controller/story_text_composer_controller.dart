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
  Color _selectedTextColor = textColors.first;
  int _textStyleIndex = 0;

  String get selectedMusic => _selectedMusic;
  int get gradientIndex => _gradientIndex;
  Color get selectedTextColor => _selectedTextColor;
  int get textStyleIndex => _textStyleIndex;
  bool get hasText => textController.text.trim().isNotEmpty;
  bool get showMusic => config.startWithMusic || _selectedMusic.isNotEmpty;
  String get currentText => textController.text.trim();

  FontWeight get selectedFontWeight {
    switch (_textStyleIndex) {
      case 1:
        return FontWeight.w500;
      case 2:
        return FontWeight.w800;
      default:
        return FontWeight.w700;
    }
  }

  FontStyle get selectedFontStyle {
    return _textStyleIndex == 1 ? FontStyle.italic : FontStyle.normal;
  }

  String? get selectedFontFamily {
    switch (_textStyleIndex) {
      case 1:
        return 'serif';
      case 2:
        return 'monospace';
      default:
        return null;
    }
  }

  double get selectedLetterSpacing {
    return _textStyleIndex == 2 ? 1.2 : 0;
  }

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
    final int currentIndex = textColors.indexOf(_selectedTextColor);
    final int safeIndex = currentIndex < 0 ? 0 : currentIndex;
    _selectedTextColor = textColors[(safeIndex + 1) % textColors.length];
    notifyListeners();
  }

  void setTextColor(Color color) {
    _selectedTextColor = color;
    notifyListeners();
  }

  void cycleTextStyle() {
    _textStyleIndex = (_textStyleIndex + 1) % 3;
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
