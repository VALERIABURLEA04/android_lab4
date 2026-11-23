import 'package:material_ui/material_ui.dart';

import '../domain/catalog.dart';
import '../domain/catalog_repository.dart';
import 'catalog_photos.dart';

const ink = Color(0xFF1D1F22);
const muted = Color(0xFF737D90);
const accent = Color(0xFF508A7B);
const soft = Color(0xFFF8F8FA);
const dividerColor = Color(0xFFEEF0F1);
const inset = 32.0;

String priceLabel(double price, String currency) =>
    '${currency == 'USD' ? r'$' : currency} ${price.toStringAsFixed(2)}';

String catalogErrorMessage(Object? failure) =>
    switch (failure is CatalogFailure ? failure.error : null) {
      CatalogError.timeout => 'The server took too long to respond.',
      CatalogError.network => 'Check your internet connection.',
      CatalogError.server => 'The store is temporarily unavailable.',
      CatalogError.invalidData => 'The store returned an unreadable response.',
      CatalogError.unavailable => 'Product details are unavailable.',
      null => 'Something went wrong.',
    };

class AsyncContent<T> extends StatelessWidget {
  const AsyncContent({
    super.key,
    required this.future,
    required this.onRetry,
    required this.builder,
  });

  final Future<T> future;
  final VoidCallback onRetry;
  final Widget Function(T) builder;

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(
          child: CircularProgressIndicator(semanticsLabel: 'Loading'),
        );
      }
      if (snapshot.hasData) return builder(snapshot.data as T);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(inset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 40),
              const SizedBox(height: 16),
              Text(
                catalogErrorMessage(snapshot.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              FilledButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      );
    },
  );
}

class CatalogPhoto extends StatelessWidget {
  const CatalogPhoto(
    this.url, {
    super.key,
    this.asset,
    this.alignment = Alignment.center,
    this.fit = BoxFit.cover,
  });

  final String url;
  final String? asset;
  final Alignment alignment;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: soft,
    child: asset != null
        ? Image.asset(
            asset!,
            width: double.infinity,
            height: double.infinity,
            fit: fit,
            alignment: alignment,
            excludeFromSemantics: true,
          )
        : Image.network(
            url,
            width: double.infinity,
            height: double.infinity,
            fit: fit,
            alignment: alignment,
            excludeFromSemantics: true,
            errorBuilder: (_, _, _) => const Center(
              child: Icon(Icons.image_not_supported_outlined, color: muted),
            ),
          ),
  );
}

class PlacedArtwork extends StatelessWidget {
  const PlacedArtwork(this.asset, this.bounds, {super.key});

  final String asset;
  final Rect bounds;

  @override
  Widget build(BuildContext context) => Positioned.fromRect(
    rect: bounds,
    child: Image.asset(asset, fit: BoxFit.fill, excludeFromSemantics: true),
  );
}

class PageDots extends StatelessWidget {
  const PageDots({
    super.key,
    required this.count,
    required this.active,
    this.color = ink,
  });

  final int count;
  final int active;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(count, (index) {
      final selected = index == active;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: selected ? Border.all(color: color, width: .9) : null,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 4.5,
            height: 4.5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      );
    }),
  );
}

class ProductRail extends StatelessWidget {
  const ProductRail({
    super.key,
    required this.products,
    required this.onProduct,
    this.compact = false,
    this.boldName = false,
  });

  final List<ProductSummary> products;
  final ValueChanged<ProductSummary> onProduct;
  final bool compact;
  final bool boldName;

  @override
  Widget build(BuildContext context) {
    final photos = CatalogPhotos.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final labelHeight =
        (textScaler.scale(11) + textScaler.scale(14)) * 1.5 +
        (boldName ? 4 : 2);
    final railHeight = compact
        ? (labelHeight + 2).clamp(67.0, double.infinity)
        : (172 + (boldName ? 15 : 12) + labelHeight + 1).clamp(
            boldName ? 230.0 : 222.0,
            double.infinity,
          );
    return SizedBox(
      height: railHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: boldName && !compact ? 35 : inset,
        ),
        itemCount: products.length,
        separatorBuilder: (_, _) => SizedBox(width: compact ? 16 : 20),
        itemBuilder: (context, index) {
          final product = products[index];
          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onProduct(product),
            child: compact
                ? SizedBox(
                    width: 212,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: soft),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        children: [
                          SizedBox.square(
                            dimension: 65,
                            child: _photo(photos, product),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: _text(product),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    width: 126,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 172, child: _photo(photos, product)),
                        SizedBox(height: boldName ? 15 : 12),
                        _text(product),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _photo(PhotoLibrary photos, ProductSummary product) {
    final asset = photos.assetFor(PhotoSlot.product, product.id);
    final bounds = asset == null
        ? null
        : photos.cropFor(asset, compact: compact);
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: asset != null && bounds != null
          ? ColoredBox(
              color: soft,
              child: Stack(
                fit: StackFit.expand,
                children: [PlacedArtwork(asset, bounds)],
              ),
            )
          : CatalogPhoto(
              product.imageUrl,
              asset: asset,
              alignment: Alignment.topCenter,
            ),
    );
  }

  Widget _text(ProductSummary product) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        product.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: boldName || compact ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      SizedBox(height: boldName ? 4 : 2),
      Text(
        priceLabel(product.price, product.currency),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ],
  );
}
