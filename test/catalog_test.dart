import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemstore_lab4/data/catalog_api.dart';
import 'package:gemstore_lab4/data/catalog_dtos.dart';
import 'package:gemstore_lab4/domain/catalog_repository.dart';
import 'package:gemstore_lab4/main.dart';
import 'package:gemstore_lab4/presentation/shop_session.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late String feedJson;
  late String detailsJson;

  setUpAll(() {
    feedJson = File('test/fixtures/feed.json').readAsStringSync();
    detailsJson = File('test/fixtures/details.json').readAsStringSync();
  });

  test('both DTOs deserialize and serialize the full V1 payload', () {
    final feed = jsonDecode(feedJson) as Map<String, dynamic>;
    final details = jsonDecode(detailsJson)['product'] as Map<String, dynamic>;
    expect(FeedDto.fromJson(feed).toJson(), equals(feed));
    expect(ProductDetailsDto.fromJson(details).toJson(), equals(details));
  });

  test(
    'session reviews survive navigation and are scoped to their product',
    () {
      final json = jsonDecode(detailsJson)['product'] as Map<String, dynamic>;
      final product = ProductDetailsDto.fromJson(json).toEntity();
      final session = ShopSession();
      addTearDown(session.dispose);

      session.addReview(product.id, product.reviews.first);

      expect(session.reviewsFor(product.id), [product.reviews.first]);
      expect(session.reviewsFor('p001'), isEmpty);
      expect(product.reviewCount, 47);
    },
  );

  test(
    'repository calls both V1 URLs and verifies the returned product ID',
    () async {
      final requests = <String>[];
      final remote = CatalogRemoteDataSource(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.headers['accept'], 'application/json');
          requests.add(request.url.path);
          return http.Response(
            request.url.path.endsWith('/details') ? detailsJson : feedJson,
            200,
          );
        }),
      );
      final repository = RemoteCatalogRepository(remote);
      expect((await repository.getFeed()).storeName, 'GemStore');
      final product = await repository.getDetails('p003');
      expect(product.reviewCount, 47);
      expect(product.sizeAvailability, {'S': false, 'M': false, 'L': true});
      await expectLater(
        repository.getDetails('p001'),
        throwsA(_failure(CatalogError.unavailable)),
      );
      expect(requests, [
        '/lab2026/v1/feed',
        '/lab2026/v1/feed/details',
        '/lab2026/v1/feed/details',
      ]);
    },
  );

  test(
    'HTTP, network, timeout and invalid payload failures are typed',
    () async {
      Future<void> verify(CatalogError error, MockClientHandler handler) =>
          expectLater(
            CatalogRemoteDataSource(
              MockClient(handler),
              timeout: Duration.zero,
            ).fetchFeed(),
            throwsA(_failure(error)),
          );
      await verify(CatalogError.server, (_) async => http.Response('', 503));
      await verify(
        CatalogError.invalidData,
        (_) async => http.Response('{"storeName":7}', 200),
      );
      await verify(
        CatalogError.invalidData,
        (_) async => http.Response('bad json', 200),
      );
      await verify(
        CatalogError.network,
        (_) async => throw http.ClientException('Offline'),
      );
      await verify(
        CatalogError.timeout,
        (_) => Completer<http.Response>().future,
      );
    },
  );

  testWidgets('loading, retry, live-shaped feed, details and cart flow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final firstResponse = Completer<http.Response>();
    var attempts = 0;
    final repository = RemoteCatalogRepository(
      CatalogRemoteDataSource(
        MockClient((request) async {
          if (request.url.path.endsWith('/details')) {
            return http.Response(detailsJson, 200);
          }
          return ++attempts == 1
              ? firstResponse.future
              : http.Response(feedJson, 200);
        }),
      ),
    );
    await tester.pumpWidget(GemStoreApp(repository: repository));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    firstResponse.complete(http.Response('', 503));
    await tester.pumpAndSettle();
    expect(find.text('The store is temporarily unavailable.'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('GemStore'), findsOneWidget);
    expect(find.text('Feature Products'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/figma/banner-autumn-collection-2021.jpeg',
      ),
      findsOneWidget,
    );
    await tester.tap(_photo('product-p001.jpeg'));
    await tester.pumpAndSettle();
    expect(find.text('Turtleneck Sweater'), findsOneWidget);
    expect(find.text(r'$ 39.99'), findsOneWidget);
    expect(_photo('product-p001.jpeg'), findsOneWidget);
    expect(find.text('Sportwear Set'), findsNothing);
    expect(find.text('Description'), findsOneWidget);
    expect(
      find.text('No description was provided for this product.'),
      findsOneWidget,
    );
    expect(find.text('View Sportwear Set'), findsNothing);
    final addToCart = find.text('Add To Cart').hitTestable();
    await tester.scrollUntilVisible(
      addToCart,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(addToCart);
    await tester.pumpAndSettle();
    expect(
      find.text('Purchase options are unavailable for this product.'),
      findsOneWidget,
    );
    expect(find.text('Shopping bag'), findsNothing);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).at(1), const Offset(-210, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sportwear Set'));
    await tester.pumpAndSettle();
    expect(find.text('Sportwear Set'), findsOneWidget);
    expect(find.text(r'$ 80.00'), findsOneWidget);
    expect(_photo('product-p003.png'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(_photo('cover-p003.png'), findsOneWidget);
    expect(find.byTooltip('Remove from favorites'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove from favorites'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Add to favorites'), findsOneWidget);
    await tester.dragFrom(const Offset(180, 650), const Offset(0, -270));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read more'));
    await tester.pumpAndSettle();
    expect(find.text('Show less'), findsOneWidget);
    await tester.scrollUntilVisible(
      addToCart,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(addToCart);
    await tester.pumpAndSettle();
    expect(find.text('Shopping bag'), findsOneWidget);
    expect(find.text('Sportwear Set added to your bag.'), findsOneWidget);
    expect(find.text(r'Beige · L · $ 80.00'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Your bag is empty.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Matcher _failure(CatalogError error) =>
    isA<CatalogFailure>().having((failure) => failure.error, 'error', error);

Finder _photo(String name) => find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName == 'assets/figma/$name',
);
