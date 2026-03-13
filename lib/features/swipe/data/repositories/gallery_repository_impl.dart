import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/gallery_repository.dart';
import '../datasources/gallery_datasource.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  final GalleryDataSource dataSource;
  final SharedPreferences prefs;

  const GalleryRepositoryImpl({
    required this.dataSource,
    required this.prefs,
  });

  @override
  Future<List<AssetEntity>> loadPhotos({int page = 0, int pageSize = 120}) {
    return dataSource.loadPhotos(page: page, pageSize: pageSize);
  }

  @override
  Future<void> deletePhoto(String photoId) {
    return dataSource.deletePhoto(photoId);
  }

  @override
  Future<void> favoritePhoto(String photoId) async {
    final favorites = prefs.getStringList('sortly_favorites') ?? [];
    if (!favorites.contains(photoId)) {
      favorites.add(photoId);
      await prefs.setStringList('sortly_favorites', favorites);
    }
  }
}
