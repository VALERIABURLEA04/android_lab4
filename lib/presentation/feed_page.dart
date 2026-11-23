import 'package:material_ui/material_ui.dart' hide Banner;

import '../domain/catalog.dart';
import '../domain/catalog_repository.dart';
import 'common.dart';
import 'catalog_photos.dart';
import 'product_page.dart';
import 'shopping_bag.dart';
import 'shop_session.dart';
import 'store_icon.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({
    super.key,
    required this.getFeed,
    required this.getDetails,
    required this.session,
  });

  final GetFeed getFeed;
  final GetProductDetails getDetails;
  final ShopSession session;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _scaffold = GlobalKey<ScaffoldState>();
  late Future<Feed> _feed;
  String? _category;
  bool _openingDetails = false;

  @override
  void initState() {
    super.initState();
    _feed = widget.getFeed();
  }

  Future<void> _reload() async {
    final request = widget.getFeed();
    setState(() {
      _feed = request;
    });
    try {
      await request;
    } on CatalogFailure {
      // AsyncContent displays the error and the retry action.
    }
  }

  Future<void> _open(ProductSummary product) async {
    if (_openingDetails) return;
    _openingDetails = true;
    try {
      await ProductPage.open(
        context,
        summary: product,
        getDetails: widget.getDetails,
        session: widget.session,
      );
    } finally {
      _openingDetails = false;
    }
  }

  void _showList(String title, List<ProductSummary> products) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            for (final product in products)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(product.name),
                subtitle: Text(priceLabel(product.price, product.currency)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _open(product);
                },
              ),
            if (products.isEmpty)
              const ListTile(title: Text('No products available.')),
          ],
        ),
      ),
    );
  }

  void _showCollections(Feed feed) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(inset, 0, inset, 20),
          children: [
            for (final item in feed.topCollections) ...[
              _CollectionCard(item: item, height: 140),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    key: _scaffold,
    drawer: Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text('Shopping bag'),
              onTap: () {
                Navigator.pop(context);
                showShoppingBag(context, widget.session);
              },
            ),
          ],
        ),
      ),
    ),
    body: SafeArea(
      minimum: const EdgeInsets.only(top: 44),
      child: AsyncContent<Feed>(
        future: _feed,
        onRetry: _reload,
        builder: (feed) => Column(
          children: [
            SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Menu',
                      onPressed: () => _scaffold.currentState?.openDrawer(),
                      icon: const StoreIcon(
                        StoreGlyph.menu,
                        width: 20,
                        height: 19,
                        color: Color(0xFF2D2B2B),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        feed.storeName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Notifications',
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Notifications'),
                          content: const Text('You have no new notifications.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                      icon: Transform.translate(
                        offset: const Offset(-4, 0),
                        child: const StoreIcon(
                          StoreGlyph.notifications,
                          width: 26,
                          height: 26,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _reload,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 17, 22, 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (final category in feed.categories)
                            Flexible(
                              child: SizedBox(
                                width: 61,
                                child: _CategoryButton(
                                  category: category,
                                  selected: _category == null
                                      ? category.selected
                                      : _category == category.id,
                                  onTap: () =>
                                      setState(() => _category = category.id),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: inset),
                      child: _HeroBanner(
                        banner: feed.heroBanner,
                        onTap: () => _showList(
                          feed.heroBanner.title,
                          feed.featureProducts,
                        ),
                      ),
                    ),
                    _Heading(
                      'Feature Products',
                      spaceAfter: 10,
                      onShow: () =>
                          _showList('Feature Products', feed.featureProducts),
                    ),
                    if (feed.featureProducts.isNotEmpty)
                      ProductRail(
                        products: feed.featureProducts,
                        onProduct: _open,
                        boldName: true,
                      ),
                    const SizedBox(height: 17),
                    _CollectionCard(
                      item: feed.newCollection,
                      height: 157,
                      radius: 0,
                      contentInset: 55,
                    ),
                    _Heading(
                      'Recommended',
                      spaceBefore: 27,
                      spaceAfter: 20,
                      onShow: () => _showList('Recommended', feed.recommended),
                    ),
                    if (feed.recommended.isNotEmpty)
                      ProductRail(
                        products: feed.recommended,
                        onProduct: _open,
                        compact: true,
                      ),
                    _Heading(
                      'Top Collection',
                      onShow: () => _showCollections(feed),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(inset, 12, inset, 17),
                      child: Column(
                        children: [
                          for (final (index, item)
                              in feed.topCollections.indexed) ...[
                            _CollectionCard(
                              item: item,
                              height: index == 0 ? 141 : 211,
                              emphasized: index > 0,
                            ),
                            const SizedBox(height: 15),
                          ],
                          Wrap(
                            spacing: 9,
                            runSpacing: 10,
                            children: [
                              for (final (index, promo)
                                  in feed.categoryPromos.indexed)
                                FractionallySizedBox(
                                  widthFactor: .478,
                                  child: _PromoCard(
                                    promo: promo,
                                    imageOnLeft: index.isEven,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: const Color(0xFF3A2C27))
                  : null,
            ),
            child: Center(child: _categoryArtwork()),
          ),
          const SizedBox(height: 5),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w300,
              color: selected ? ink : const Color(0xFF858585),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _categoryArtwork() {
    final glyph = switch (category.id) {
      'women' => StoreGlyph.women,
      'men' => StoreGlyph.men,
      'accessories' => StoreGlyph.glasses,
      'beauty' => StoreGlyph.lipstick,
      _ => null,
    };
    final color = selected ? Colors.white : const Color(0xFFA1A1A1);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? const Color(0xFF3A2C27) : const Color(0xFFF4F4F4),
      ),
      alignment: Alignment.center,
      child: glyph == null
          ? Icon(Icons.category_outlined, size: 17, color: color)
          : StoreIcon(
              glyph,
              width: glyph == StoreGlyph.women ? 19 : 21,
              height: glyph == StoreGlyph.women || glyph == StoreGlyph.lipstick
                  ? 21
                  : 20,
              color: color,
            ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.banner, required this.onTap});
  final Banner banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final artwork = CatalogPhotos.of(
      context,
    ).assetFor(PhotoSlot.banner, banner.id);
    return Semantics(
      button: true,
      label: banner.action,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 168,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (artwork != null)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final scale = constraints.maxWidth / 311;
                      return Stack(
                        children: [
                          PlacedArtwork(
                            artwork,
                            Rect.fromLTWH(
                              -9.2 * scale,
                              (168 - 214.5 * scale) / 2 + 9.5,
                              321.1 * scale,
                              214.5 * scale,
                            ),
                          ),
                        ],
                      );
                    },
                  )
                else
                  CatalogPhoto(banner.imageUrl),
                if (artwork == null)
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0x78000000)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                Positioned(
                  top: 17,
                  right: 8,
                  width: 116,
                  child: Text(
                    banner.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (banner.slides > 1)
                  Positioned(
                    bottom: 8,
                    left: 5,
                    right: 0,
                    child: Center(
                      child: PageDots(
                        count: banner.slides,
                        active: banner.activeSlide,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(
    this.title, {
    required this.onShow,
    this.spaceBefore = 23,
    this.spaceAfter = 9,
  });

  final String title;
  final VoidCallback onShow;
  final double spaceBefore;
  final double spaceAfter;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(inset, spaceBefore, inset - 8, spaceAfter),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        TextButton(
          onPressed: onShow,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF808080),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w300,
            ),
          ),
          child: const Text('Show all'),
        ),
      ],
    ),
  );
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.item,
    required this.height,
    this.radius = 11,
    this.contentInset = 23,
    this.emphasized = false,
  });

  final Collection item;
  final double height;
  final double radius;
  final double contentInset;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNew = item.id == null;
          final artwork = CatalogPhotos.of(
            context,
          ).assetFor(PhotoSlot.collection, item.id ?? 'new');
          final title = item.title.replaceFirst(' & ', '\n& ');
          final photoWidth = isNew
              ? 250.7
              : emphasized
              ? 152.7
              : 128.7;
          final photoHeight = isNew
              ? 167.3
              : emphasized
              ? 228.9
              : 229.0;
          return Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: soft),
              if (artwork != null) ...[
                Positioned(
                  right: isNew ? 16 : 32,
                  top: isNew
                      ? 4
                      : emphasized
                      ? 41
                      : 23,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDEDEE),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(
                      dimension: isNew
                          ? 132
                          : emphasized
                          ? 114
                          : 85,
                    ),
                  ),
                ),
                Positioned(
                  top: isNew
                      ? -10.4
                      : emphasized
                      ? -19.2
                      : -60,
                  right: isNew
                      ? -42.6
                      : emphasized
                      ? -1
                      : 1.6,
                  width: photoWidth,
                  height: photoHeight,
                  child: Image.asset(
                    artwork,
                    fit: BoxFit.fill,
                    excludeFromSemantics: true,
                  ),
                ),
              ] else
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: constraints.maxWidth * .47,
                  child: CatalogPhoto(
                    item.imageUrl,
                    alignment: Alignment.topCenter,
                  ),
                ),
              if (artwork == null)
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: constraints.maxWidth * .37,
                  width: 40,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [soft, Color(0x00F5F5F7)],
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: contentInset,
                right: constraints.maxWidth * .42,
                top: isNew
                    ? 31
                    : emphasized
                    ? 33
                    : 22,
                bottom: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '│ ${item.label}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: muted,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: emphasized ? 24 : 18),
                    Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: artwork == null ? double.infinity : 113,
                        ),
                        child: Text(
                          title,
                          maxLines: emphasized ? 3 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.32,
                            color: emphasized ? ink : muted,
                            fontWeight: emphasized
                                ? FontWeight.w600
                                : FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.promo, required this.imageOnLeft});
  final CategoryPromo promo;
  final bool imageOnLeft;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: SizedBox(
      height: 194,
      child: ColoredBox(
        color: soft,
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              if (CatalogPhotos.of(context).assetFor(PhotoSlot.promo, promo.id)
                  case final String artwork)
                PlacedArtwork(
                  artwork,
                  imageOnLeft
                      ? const Rect.fromLTWH(-127.8, -56.7, 279.5, 355)
                      : const Rect.fromLTWH(50.4, -21.3, 152.7, 228.8),
                )
              else
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: imageOnLeft ? -52 : null,
                  right: imageOnLeft ? null : -31,
                  width: 158,
                  child: CatalogPhoto(
                    promo.imageUrl,
                    alignment: Alignment.topCenter,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              Positioned(
                left: imageOnLeft ? constraints.maxWidth * .56 : 8,
                right: imageOnLeft ? 5 : constraints.maxWidth * .48,
                top: 39,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      promo.category,
                      style: const TextStyle(fontSize: 12, color: muted),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      promo.title,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.36,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
