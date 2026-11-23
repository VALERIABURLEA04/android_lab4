import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'data/catalog_api.dart';
import 'domain/catalog_repository.dart';
import 'presentation/catalog_photos.dart';
import 'presentation/common.dart';
import 'presentation/feed_page.dart';
import 'presentation/shop_session.dart';

void main() => runApp(const GemStoreApp());

const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');
const _webDevelopmentApiBaseUrl = 'http://127.0.0.1:8081/lab2026/v1/';

class GemStoreApp extends StatefulWidget {
  const GemStoreApp({super.key, this.repository});

  final CatalogRepository? repository;

  @override
  State<GemStoreApp> createState() => _GemStoreAppState();
}

class _GemStoreAppState extends State<GemStoreApp> {
  final _session = ShopSession();
  http.Client? _client;
  late final CatalogRepository _repository;
  late final Future<PhotoLibrary> _photos;

  @override
  void initState() {
    super.initState();
    _photos = PhotoLibrary.load();
    _repository =
        widget.repository ??
        RemoteCatalogRepository(
          CatalogRemoteDataSource(
            _client = http.Client(),
            baseUrl: _configuredApiBaseUrl.isNotEmpty
                ? _configuredApiBaseUrl
                : kIsWeb
                ? _webDevelopmentApiBaseUrl
                : 'https://test-api-jlbn.onrender.com/lab2026/v1/',
          ),
        );
  }

  @override
  void dispose() {
    _client?.close();
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'GemStore',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        surface: Colors.white,
        onSurface: ink,
      ),
      scaffoldBackgroundColor: Colors.white,
      dividerTheme: const DividerThemeData(color: dividerColor, thickness: 1),
    ),
    builder: (context, child) => FutureBuilder<PhotoLibrary>(
      future: _photos,
      builder: (context, snapshot) => CatalogPhotos(
        library: snapshot.data ?? PhotoLibrary.empty,
        child: ColoredBox(
          color: const Color(0xFFF2F2F2),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: child,
            ),
          ),
        ),
      ),
    ),
    home: FeedPage(
      getFeed: GetFeed(_repository),
      getDetails: GetProductDetails(_repository),
      session: _session,
    ),
  );
}
