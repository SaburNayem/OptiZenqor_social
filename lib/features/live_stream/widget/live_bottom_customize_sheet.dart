import 'package:flutter/material.dart';

import '../controller/live_stream_controller.dart';
import '../model/live_stream_model.dart';

class LiveBottomCustomizeSheet extends StatelessWidget {
  const LiveBottomCustomizeSheet({
    required this.controller,
    required this.onCancel,
    required this.onApplyAndGoLive,
    super.key,
  });

  final LiveStreamController controller;
  final VoidCallback onCancel;
  final VoidCallback onApplyAndGoLive;

  static Future<void> show(
    BuildContext context, {
    required LiveStreamController controller,
    required VoidCallback onApplyAndGoLive,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return LiveBottomCustomizeSheet(
          controller: controller,
          onCancel: () => Navigator.of(context).pop(),
          onApplyAndGoLive: onApplyAndGoLive,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.86,
          decoration: const BoxDecoration(
            color: Color(0xFF111827),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 1,
            minChildSize: 0.7,
            maxChildSize: 1,
            builder: (context, scrollController) {
              return Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Live setup',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      children: [
                        _sectionTitle('Live setup'),
                        _inputField(
                          label: 'Title',
                          controller: controller.titleController,
                          onSubmitted: controller.applyTitle,
                        ),
                        _inputField(
                          label: 'Description',
                          controller: controller.descriptionController,
                          maxLines: 3,
                          onSubmitted: controller.applyDescription,
                        ),
                        _dropdownField<LiveAudienceVisibility>(
                          label: 'Audience',
                          value: controller.audience,
                          items: const {
                            LiveAudienceVisibility.public: 'Public',
                            LiveAudienceVisibility.friends: 'Friends',
                            LiveAudienceVisibility.onlyMe: 'Only me',
                          },
                          onChanged: controller.setAudience,
                        ),
                        _dropdownField<String>(
                          label: 'Category',
                          value: controller.category,
                          items: const {
                            'Creator Studio': 'Creator Studio',
                            'Lifestyle': 'Lifestyle',
                            'Gaming': 'Gaming',
                            'Music': 'Music',
                          },
                          onChanged: controller.setCategory,
                        ),
                        _switchTile(
                          'Allow comments',
                          controller.allowComments,
                          controller.setAllowComments,
                        ),
                        _switchTile(
                          'Allow reactions',
                          controller.allowReactions,
                          controller.setAllowReactions,
                        ),
                        _switchTile(
                          'Save live replay',
                          controller.saveReplay,
                          controller.setSaveReplay,
                        ),
                        _switchTile(
                          'Notify followers',
                          controller.notifyFollowers,
                          controller.setNotifyFollowers,
                        ),
                        _sectionTitle('Camera and audio'),
                        _dropdownField<String>(
                          label: 'Camera source',
                          value: controller.cameraSource,
                          items: const {
                            'Front camera': 'Front camera',
                            'Back camera': 'Back camera',
                          },
                          onChanged: controller.setCameraSource,
                        ),
                        _dropdownField<String>(
                          label: 'Mic source',
                          value: controller.micSource,
                          items: const {
                            'Built-in microphone': 'Built-in microphone',
                            'Wireless mic': 'Wireless mic',
                            'USB audio': 'USB audio',
                          },
                          onChanged: controller.setMicSource,
                        ),
                        _switchTile(
                          'Enable noise reduction',
                          controller.noiseReduction,
                          controller.setNoiseReduction,
                        ),
                        _sliderTile(
                          label: 'Beauty mode',
                          value: controller.beautyMode,
                          onChanged: controller.setBeautyMode,
                        ),
                        _sliderTile(
                          label: 'Brightness',
                          value: controller.brightness,
                          onChanged: controller.setBrightness,
                        ),
                        _sliderTile(
                          label: 'Contrast',
                          value: controller.contrast,
                          onChanged: controller.setContrast,
                        ),
                        _switchTile(
                          'Mirror preview',
                          controller.mirrorPreview,
                          controller.setMirrorPreview,
                        ),
                        _sectionTitle('Interaction settings'),
                        _switchTile(
                          'Enable live chat',
                          controller.enableLiveChat,
                          controller.setEnableLiveChat,
                        ),
                        _switchTile(
                          'Slow mode',
                          controller.slowMode,
                          controller.setSlowMode,
                        ),
                        _inputField(
                          label: 'Pinned comment',
                          controller: controller.pinnedCommentController,
                          onSubmitted: controller.updatePinnedComment,
                        ),
                        _switchTile(
                          'Allow viewer questions',
                          controller.allowViewerQuestions,
                          controller.setAllowViewerQuestions,
                        ),
                        _switchTile(
                          'Show viewer count',
                          controller.showViewerCount,
                          controller.setShowViewerCount,
                        ),
                        _switchTile(
                          'Show hearts/reactions overlay',
                          controller.showReactionOverlay,
                          controller.setShowReactionOverlay,
                        ),
                        _switchTile(
                          'Moderator mode',
                          controller.moderatorMode,
                          controller.setModeratorMode,
                        ),
                        _sectionTitle('Monetization and extras'),
                        _switchTile(
                          'Enable stars/gifts',
                          controller.enableStars,
                          controller.setEnableStars,
                        ),
                        _switchTile(
                          'Raise money',
                          controller.raiseMoney,
                          controller.setRaiseMoney,
                        ),
                        _switchTile(
                          'Add product links',
                          controller.productLinks,
                          controller.setProductLinks,
                        ),
                        _switchTile(
                          'Add donation banner',
                          controller.donationBanner,
                          controller.setDonationBanner,
                        ),
                        _switchTile(
                          'Enable subscriber-only chat',
                          controller.subscriberOnlyChat,
                          controller.setSubscriberOnlyChat,
                        ),
                        _sectionTitle('Safety and privacy'),
                        _dropdownField<LiveAudienceVisibility>(
                          label: 'Privacy visibility',
                          value: controller.audience,
                          items: const {
                            LiveAudienceVisibility.public: 'Public',
                            LiveAudienceVisibility.friends: 'Friends',
                            LiveAudienceVisibility.onlyMe: 'Only me',
                          },
                          onChanged: controller.setAudience,
                        ),
                        _actionTile('Block certain words'),
                        _switchTile(
                          'Hide offensive comments',
                          controller.hideOffensiveComments,
                          controller.setHideOffensiveComments,
                        ),
                        _switchTile(
                          'Age restriction',
                          controller.ageRestriction,
                          controller.setAgeRestriction,
                        ),
                        _dropdownField<String>(
                          label: 'Region restriction',
                          value: controller.regionRestriction,
                          items: const {
                            'None': 'None',
                            'South Asia': 'South Asia',
                            'Europe': 'Europe',
                            'North America': 'North America',
                          },
                          onChanged: controller.setRegionRestriction,
                        ),
                        _sectionTitle('Visual customization'),
                        _colorRow(),
                        _dropdownField<String>(
                          label: 'Live badge style',
                          value: controller.badgeStyle,
                          items: const {
                            'Pulse': 'Pulse',
                            'Solid': 'Solid',
                            'Soft glow': 'Soft glow',
                          },
                          onChanged: controller.setBadgeStyle,
                        ),
                        _dropdownField<String>(
                          label: 'Comment bubble style',
                          value: controller.commentBubbleStyle,
                          items: const {
                            'Glass': 'Glass',
                            'Soft card': 'Soft card',
                            'Compact': 'Compact',
                          },
                          onChanged: controller.setCommentBubbleStyle,
                        ),
                        _dropdownField<String>(
                          label: 'Reaction style',
                          value: controller.reactionStyle,
                          items: const {
                            'Classic': 'Classic',
                            'Neon': 'Neon',
                            'Soft pop': 'Soft pop',
                          },
                          onChanged: controller.setReactionStyle,
                        ),
                        _sliderTile(
                          label: 'Font scale',
                          value: controller.fontScale,
                          min: 0.85,
                          max: 1.3,
                          onChanged: controller.setFontScale,
                        ),
                        _sliderTile(
                          label: 'Overlay opacity',
                          value: controller.overlayOpacity,
                          min: 0.45,
                          max: 1.0,
                          onChanged: controller.setOverlayOpacity,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
                    decoration: const BoxDecoration(
                      color: Color(0xFF111827),
                      border: Border(top: BorderSide(color: Colors.white12)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onCancel,
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: controller.resetSetup,
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Save setup'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onApplyAndGoLive,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Apply & go'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onSubmitted,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onSubmitted: onSubmitted,
        onChanged: onSubmitted,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _switchTile(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _sliderTile({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0,
    double max = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required T value,
    required Map<T, String> items,
    required ValueChanged<T> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: DropdownButton<T>(
        value: value,
        dropdownColor: const Color(0xFF1B2430),
        style: const TextStyle(color: Colors.white),
        onChanged: (next) {
          if (next != null) {
            onChanged(next);
          }
        },
        items: items.entries
            .map(
              (entry) => DropdownMenuItem<T>(
                value: entry.key,
                child: Text(entry.value),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _actionTile(String label) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white70),
    );
  }

  Widget _colorRow() {
    const colors = <int>[
      0xFF26C6DA,
      0xFFE53935,
      0xFF8E24AA,
      0xFF43A047,
      0xFFFFB300,
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: colors.map((value) {
          final selected = controller.themeColor == value;
          return GestureDetector(
            onTap: () => controller.setThemeColor(value),
            child: Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Color(value),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
