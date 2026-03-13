import 'package:photo_manager/photo_manager.dart';

abstract class GalleryRepository {
  Future<List<AssetEntity>> loadPhotos({int page = 0, int pageSize = 120});
  Future<void> deletePhoto(String photoId);
  Future<void> favoritePhoto(String photoId);
}
