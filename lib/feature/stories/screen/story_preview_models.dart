part of 'story_preview_screen.dart';

class _StoryToolConfig {
  const _StoryToolConfig({
    required this.label,
    required this.onTap,
    this.icon,
    this.textIcon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final String? textIcon;
}
