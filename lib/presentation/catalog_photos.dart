import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

enum PhotoSlot { banner, collection, cover, product, promo, review }

class CatalogPhotos extends InheritedWidget {
  const CatalogPhotos({super.key, required this.library, required super.child});

  final PhotoLibrary library;

  static PhotoLibrary of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CatalogPhotos>()?.library ??
      PhotoLibrary.empty;

  @override
  bool updateShouldNotify(CatalogPhotos oldWidget) =>
      library != oldWidget.library;
}

class PhotoLibrary {
  const PhotoLibrary._(this._assets, this._framing);

  static const empty = PhotoLibrary._({}, {});
  static const _directory = 'assets/figma';

  final Set<String> _assets;
  final Map<String, dynamic> _framing;

  static Future<PhotoLibrary> load() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final framingSource = await rootBundle.loadString(
      'assets/photo_framing.json',
    );
    return PhotoLibrary._(
      manifest
          .listAssets()
          .where((asset) => asset.startsWith('$_directory/'))
          .toSet(),
      jsonDecode(framingSource) as Map<String, dynamic>,
    );
  }

  String? assetFor(PhotoSlot slot, String id) {
    for (final extension in const ['png', 'jpeg', 'jpg']) {
      final path = '$_directory/${slot.name}-$id.$extension';
      if (_assets.contains(path)) return path;
    }
    return null;
  }

  Rect? cropFor(String asset, {required bool compact}) {
    final name = asset.split('/').last;
    final frames = _framing[name] as Map<String, dynamic>?;
    final bounds = frames?[compact ? 'compact' : 'rail'] as List<dynamic>?;
    if (bounds == null) return null;
    return Rect.fromLTWH(
      (bounds[0] as num).toDouble(),
      (bounds[1] as num).toDouble(),
      (bounds[2] as num).toDouble(),
      (bounds[3] as num).toDouble(),
    );
  }
}
