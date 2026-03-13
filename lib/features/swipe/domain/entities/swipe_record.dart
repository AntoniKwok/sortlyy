import 'package:photo_manager/photo_manager.dart';

enum SwipeAction { delete, keep, favorite }

class SwipeRecord {
  final AssetEntity photo;
  final SwipeAction action;

  const SwipeRecord({required this.photo, required this.action});
}
