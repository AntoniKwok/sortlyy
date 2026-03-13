import 'package:photo_manager/photo_manager.dart';

/// A single item in the swipe queue — either one photo or a group of
/// visually similar photos discovered by on-device perceptual hashing.
sealed class SwipeItem {
  const SwipeItem();
}

final class SinglePhoto extends SwipeItem {
  final AssetEntity photo;
  const SinglePhoto(this.photo);
}

final class PhotoGroup extends SwipeItem {
  final List<AssetEntity> photos;
  const PhotoGroup(this.photos);
}
