import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:photo_manager/photo_manager.dart';

import '../../domain/entities/swipe_item.dart';

/// On-device perceptual hashing using Flutter's built-in image codec.
/// No network calls, no third-party AI — pure local computation.
///
/// Algorithm: dHash (difference hash)
///   1. Resize image to 9×8 pixels via the native codec
///   2. Convert each pixel to luminance
///   3. For each row, compare adjacent pixel pairs → 64 bits total
///   4. Hamming distance ≤ threshold = visually similar
class PerceptualHashService {
  /// Minimum thumbnail size for hashing — small = fast, enough for similarity.
  static const _hashSize = ThumbnailSize(32, 32);

  /// Hamming distance threshold: ≤ 8 bits different = near-duplicate.
  static const int similarityThreshold = 8;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Loads tiny thumbnails and groups visually similar photos.
  /// Returns a list of [PhotoGroup]s (each with ≥ 2 similar photos).
  /// Runs entirely on-device; photos never leave the device.
  static Future<List<PhotoGroup>> findGroups(
    List<AssetEntity> photos,
  ) async {
    if (photos.length < 2) return [];

    // 1 — Load tiny thumbnails and compute hashes
    final hashes = <int>[];
    for (final photo in photos) {
      final bytes = await photo.thumbnailDataWithSize(_hashSize, quality: 15);
      hashes.add(bytes != null ? await _dHash(bytes) : 0);
    }

    // 2 — O(n²) similarity scan (fine for ≤ 120 photos)
    final assigned = List<bool>.filled(photos.length, false);
    final groups = <List<int>>[];

    for (int i = 0; i < photos.length; i++) {
      if (assigned[i]) continue;
      final group = [i];

      for (int j = i + 1; j < photos.length; j++) {
        if (assigned[j]) continue;
        if (_hammingDistance(hashes[i], hashes[j]) <= similarityThreshold) {
          group.add(j);
          assigned[j] = true;
        }
      }

      if (group.length > 1) {
        assigned[i] = true;
        groups.add(group);
      }
    }

    return groups
        .map((indices) => PhotoGroup(indices.map((i) => photos[i]).toList()))
        .toList();
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Difference hash — 64-bit fingerprint from a 9×8 grayscale thumbnail.
  static Future<int> _dHash(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 9,
        targetHeight: 8,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      if (byteData == null) return 0;

      int hash = 0;
      for (int y = 0; y < 8; y++) {
        for (int x = 0; x < 8; x++) {
          final o1 = (y * 9 + x) * 4;
          final o2 = (y * 9 + x + 1) * 4;
          final lum1 = 0.299 * byteData.getUint8(o1) +
              0.587 * byteData.getUint8(o1 + 1) +
              0.114 * byteData.getUint8(o1 + 2);
          final lum2 = 0.299 * byteData.getUint8(o2) +
              0.587 * byteData.getUint8(o2 + 1) +
              0.114 * byteData.getUint8(o2 + 2);
          if (lum1 > lum2) hash |= (1 << (y * 8 + x));
        }
      }
      return hash;
    } catch (_) {
      return 0;
    }
  }

  static int _hammingDistance(int a, int b) {
    int xor = a ^ b;
    int count = 0;
    while (xor != 0) {
      count += xor & 1;
      xor >>= 1;
    }
    return count;
  }
}
