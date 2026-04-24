import 'package:flutter/material.dart';

import '../model/story_preview_model.dart';
import '../../../core/constants/app_colors.dart';

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

  static const List<Color> textColors = <Color>[
    AppColors.white,
    AppColors.hexFFFFF176,
    AppColors.hexFF80DEEA,
    AppColors.hexFFFFAB91,
    AppColors.hexFFC5E1A5,
  ];

  final StoryPreviewModel preview;
  final TextEditingController textController;
  final FocusNode textFocusNode;

  String _selectedMusic;
  bool _isEditingText = false;
  Color _selectedTextColor = textColors.first;
  String _selectedSticker = stickerOptions.first;
  String _selectedEffect = effectOptions.first;
  String _selectedPrivacy = privacyOptions.first;
  String _mentionUsername = '';
  String _linkLabel = '';
  String _linkUrl = '';

  String get selectedMusic => _selectedMusic;
  bool get isEditingText => _isEditingText;
  Color get selectedTextColor => _selectedTextColor;
  bool get hasText => textController.text.trim().isNotEmpty;
  String get currentText => textController.text.trim();
  String get selectedSticker => _selectedSticker;
  String get selectedEffect => _selectedEffect;
  String get selectedPrivacy => _selectedPrivacy;
  String get mentionUsername => _mentionUsername;
  String get linkLabel => _linkLabel;
  String get linkUrl => _linkUrl;
  bool get hasMention => _mentionUsername.trim().isNotEmpty;
  bool get hasLink => _linkUrl.trim().isNotEmpty;

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

  @override
  void dispose() {
    textController.dispose();
    textFocusNode.dispose();
    super.dispose();
  }
}

