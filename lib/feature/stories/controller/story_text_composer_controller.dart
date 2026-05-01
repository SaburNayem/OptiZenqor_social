import 'package:flutter/material.dart';

import '../model/story_text_composer_model.dart';
import '../../../core/constants/app_colors.dart';

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
  static const List<String> stickerOptions = <String>[
    'Mood',
    'Location',
    'Flash',
    'Vibes',
    'New',
  ];
  static const List<String> effectOptions = <String>[
    'Clean',
    'Glow',
    'Film',
    'Dream',
    'Neon',
  ];
  static const List<String> privacyOptions = <String>[
    'Everyone',
    'Followers',
    'Close Friends',
  ];

  static const List<List<int>> gradients = <List<int>>[
    <int>[0xFF1E40AF, 0xFF2BB0A1],
    <int>[0xFF0F766E, 0xFF34D399],
    <int>[0xFFF59E0B, 0xFFF97316],
  ];

  static const List<Color> textColors = <Color>[
    AppColors.white,
    AppColors.hexFFFFF176,
    AppColors.hexFF80DEEA,
    AppColors.hexFFFFAB91,
    AppColors.hexFFC5E1A5,
  ];

  final StoryTextComposerModel config;
  final TextEditingController textController;
  final FocusNode textFocusNode;

  String _selectedMusic;
  int _gradientIndex = 0;
  Color _selectedTextColor = textColors.first;
  int _textStyleIndex = 0;
  String _selectedSticker = stickerOptions.first;
  String _selectedEffect = effectOptions.first;
  String _selectedPrivacy = privacyOptions.first;
  String _mentionUsername = '';
  String _linkLabel = '';
  String _linkUrl = '';

  String get selectedMusic => _selectedMusic;
  int get gradientIndex => _gradientIndex;
  Color get selectedTextColor => _selectedTextColor;
  int get textStyleIndex => _textStyleIndex;
  bool get hasText => textController.text.trim().isNotEmpty;
  bool get showMusic => config.startWithMusic || _selectedMusic.isNotEmpty;
  String get currentText => textController.text.trim();
  String get selectedSticker => _selectedSticker;
  String get selectedEffect => _selectedEffect;
  String get selectedPrivacy => _selectedPrivacy;
  String get mentionUsername => _mentionUsername;
  String get linkLabel => _linkLabel;
  String get linkUrl => _linkUrl;
  bool get hasMention => _mentionUsername.trim().isNotEmpty;
  bool get hasLink => _linkUrl.trim().isNotEmpty;

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

  void setSticker(String sticker) {
    _selectedSticker = sticker;
    notifyListeners();
  }

  void setEffect(String effect) {
    _selectedEffect = effect;
    notifyListeners();
  }

  void setPrivacy(String privacy) {
    _selectedPrivacy = privacy;
    notifyListeners();
  }

  void setMention(String username) {
    _mentionUsername = username.trim().replaceFirst('@', '');
    notifyListeners();
  }

  void setLink({required String label, required String url}) {
    _linkLabel = label.trim();
    _linkUrl = url.trim();
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
