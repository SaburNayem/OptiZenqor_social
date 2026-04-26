import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class StoryMediaOptimizer {
  const StoryMediaOptimizer({
    this.maxImageWidth = 1080,
    this.maxImageHeight = 1920,
    this.jpegQuality = 85,
  });

  final int maxImageWidth;
  final int maxImageHeight;
  final int jpegQuality;

  Future<List<String>> optimizePaths(List<String> sourcePaths) async {
    final List<String> optimized = <String>[];
    for (final String sourcePath in sourcePaths) {
      optimized.add(await optimizePath(sourcePath));
    }
    return optimized;
  }

  Future<String> optimizePath(String sourcePath) async {
    final String normalizedPath = sourcePath.trim();
    if (normalizedPath.isEmpty ||
        normalizedPath.startsWith('http://') ||
        normalizedPath.startsWith('https://') ||
        _looksLikeVideo(normalizedPath)) {
      return normalizedPath;
    }

    try {
      return await compute(
        _resizeStoryImage,
        _StoryImageResizeRequest(
          sourcePath: normalizedPath,
          maxImageWidth: maxImageWidth,
          maxImageHeight: maxImageHeight,
          jpegQuality: jpegQuality,
        ),
      );
    } catch (_) {
      return normalizedPath;
    }
  }

  bool _looksLikeVideo(String pathValue) {
    final String lower = pathValue.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.m4v') ||
        lower.endsWith('.webm');
  }
}

class _StoryImageResizeRequest {
  const _StoryImageResizeRequest({
    required this.sourcePath,
    required this.maxImageWidth,
    required this.maxImageHeight,
    required this.jpegQuality,
  });

  final String sourcePath;
  final int maxImageWidth;
  final int maxImageHeight;
  final int jpegQuality;
}

Future<String> _resizeStoryImage(_StoryImageResizeRequest request) async {
  final File sourceFile = File(request.sourcePath);
  if (!await sourceFile.exists()) {
    return request.sourcePath;
  }

  final Uint8List bytes = await sourceFile.readAsBytes();
  final img.Image? decoded = img.decodeImage(bytes);
  if (decoded == null) {
    return request.sourcePath;
  }

  final img.Image baked = img.bakeOrientation(decoded);
  final double widthScale = request.maxImageWidth / baked.width;
  final double heightScale = request.maxImageHeight / baked.height;
  final double scale = math.min(1, math.min(widthScale, heightScale));
  final bool shouldResize = scale < 1;
  final bool shouldReencode = shouldResize || bytes.lengthInBytes > 1024 * 1024;

  if (!shouldReencode) {
    return request.sourcePath;
  }

  final img.Image outputImage = shouldResize
      ? img.copyResize(
          baked,
          width: math.max(1, (baked.width * scale).round()),
          height: math.max(1, (baked.height * scale).round()),
          interpolation: img.Interpolation.average,
        )
      : baked;

  final String extension = path.extension(request.sourcePath).toLowerCase();
  final bool keepPng = extension == '.png' && outputImage.hasAlpha;
  final List<int> encoded = keepPng
      ? img.encodePng(outputImage)
      : img.encodeJpg(outputImage, quality: request.jpegQuality);
  final String outputExtension = keepPng ? '.png' : '.jpg';
  final String outputPath = path.join(
    Directory.systemTemp.path,
    'story_${DateTime.now().microsecondsSinceEpoch}_${path.basenameWithoutExtension(request.sourcePath)}$outputExtension',
  );
  final File outputFile = File(outputPath);
  await outputFile.writeAsBytes(encoded, flush: true);
  return outputFile.path;
}
