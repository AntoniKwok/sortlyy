import 'package:photo_manager/photo_manager.dart';

abstract class GalleryDataSource {
  Future<List<AssetEntity>> loadPhotos({int page = 0, int pageSize = 120});
  Future<void> deletePhoto(String photoId);
}

class GalleryDataSourceImpl implements GalleryDataSource {
  @override
  Future<List<AssetEntity>> loadPhotos({
    int page = 0,
    int pageSize = 120,
  }) async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (albums.isEmpty) return [];

    // Prefer "All Photos" / "Recents" album
    final allAlbum = albums.firstWhere(
      (a) => a.isAll,
      orElse: () => albums.first,
    );

    return allAlbum.getAssetListPaged(page: page, size: pageSize);
  }

  @override
  Future<void> deletePhoto(String photoId) async {
    await PhotoManager.editor.deleteWithIds([photoId]);
  }
}
