import 'package:material_ui/material_ui.dart';

import '../domain/catalog.dart';
import '../domain/catalog_repository.dart';
import 'common.dart';
import 'catalog_photos.dart';
import 'shopping_bag.dart';
import 'shop_session.dart';
import 'store_icon.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({
    super.key,
    required this.summary,
    required this.getDetails,
    required this.session,
  });

  final ProductSummary summary;
  final GetProductDetails getDetails;
  final ShopSession session;

  static Future<void> open(
    BuildContext context, {
    required ProductSummary summary,
    required GetProductDetails getDetails,
    required ShopSession session,
  }) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ProductPage(
        summary: summary,
        getDetails: getDetails,
        session: session,
      ),
    ),
  );

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<ProductDetails> _details;
  bool _openingDetails = false;

  @override
  void initState() {
    super.initState();
    _details = widget.getDetails(widget.summary.id);
  }

  void _retry() {
    final request = widget.getDetails(widget.summary.id);
    setState(() {
      _details = request;
    });
  }

  Future<void> _openSimilar(ProductSummary product) async {
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

  @override
  Widget build(BuildContext context) => Scaffold(
    body: FutureBuilder<ProductDetails>(
      future: _details,
      builder: (context, snapshot) => _ProductBody(
        summary: widget.summary,
        snapshot: snapshot,
        onRetry: _retry,
        session: widget.session,
        onSimilar: _openSimilar,
      ),
    ),
  );
}

class _ProductBody extends StatefulWidget {
  const _ProductBody({
    required this.summary,
    required this.snapshot,
    required this.onRetry,
    required this.session,
    required this.onSimilar,
  });
  final ProductSummary summary;
  final AsyncSnapshot<ProductDetails> snapshot;
  final VoidCallback onRetry;
  final ShopSession session;
  final ValueChanged<ProductSummary> onSimilar;

  @override
  State<_ProductBody> createState() => _ProductBodyState();
}

class _ProductBodyState extends State<_ProductBody> {
  String? _color;
  String? _size;
  bool _showDescription = true;
  late bool _fullDescription;
  bool _showReviews = true;
  bool _showSimilar = true;

  ProductDetails? get details => widget.snapshot.data;

  @override
  void initState() {
    super.initState();
    _initializeOptions();
  }

  @override
  void didUpdateWidget(covariant _ProductBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snapshot.data != details) _initializeOptions();
  }

  void _initializeOptions() {
    _color = details?.selectedColor;
    _size = details?.selectedSize;
    _fullDescription = details?.descriptionExpanded ?? false;
  }

  Future<void> _addToCart() async {
    final product = details;
    final size = _size;
    if (product == null) {
      final snapshot = widget.snapshot;
      final failure = snapshot.error;
      final String message;
      if (snapshot.connectionState != ConnectionState.done) {
        message = 'Product options are still loading.';
      } else if (failure is CatalogFailure &&
          failure.error == CatalogError.unavailable) {
        message = 'Purchase options are unavailable for this product.';
      } else {
        message = catalogErrorMessage(failure);
      }
      await _showCartMessage(message);
      return;
    }
    if (!product.actions.canAddToCart) {
      await _showCartMessage('This product is currently unavailable.');
      return;
    }
    final shade = product.availableColors
        .where((option) => option.id == _color)
        .firstOrNull;
    if (size == null ||
        shade == null ||
        product.sizeAvailability[size] != true) {
      await _showCartMessage('Select an available color and size.');
      return;
    }
    final line = CartLine(product, shade.name, size);
    widget.session.add(line);
    if (!mounted) return;
    await showShoppingBag(context, widget.session, addedLine: line);
  }

  Future<void> _showCartMessage(String message) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add To Cart'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  Future<void> _writeReview() async {
    final review = await showDialog<Review>(
      context: context,
      builder: (_) => const _ReviewDialog(),
    );
    if (mounted && review != null) {
      setState(() {
        widget.session.addReview(widget.summary.id, review);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = CatalogPhotos.of(context);
    final summary = widget.summary;
    final product = details;
    final loading = widget.snapshot.connectionState != ConnectionState.done;
    final lead = photos.assetFor(PhotoSlot.product, summary.id);
    final cover = photos.assetFor(PhotoSlot.cover, summary.id);
    final extraImages = {if (product != null) ...product.galleryImageUrls}
      ..remove(summary.imageUrl)
      ..remove(product?.mainImageUrl);
    final slides = <Widget>[
      if (lead != null && cover != null)
        _GalleryCover(asset: lead)
      else
        CatalogPhoto(summary.imageUrl, asset: lead),
      if (cover != null)
        _GalleryCover(asset: cover)
      else if (product != null && product.mainImageUrl != summary.imageUrl)
        CatalogPhoto(product.mainImageUrl, alignment: Alignment.topCenter),
      for (final url in extraImages)
        CatalogPhoto(url, alignment: Alignment.topCenter),
    ];
    final localReviews = widget.session.reviewsFor(summary.id);
    final fullDescription = product?.description ?? '';
    final words = fullDescription.trim().split(RegExp(r'\s+'));
    final canExpand = words.length > 31;
    final description = canExpand && !_fullDescription
        ? '${words.take(31).join(' ')}…'
        : fullDescription;
    final initiallyFavorite = product?.actions.isFavorite ?? false;
    final canAdd =
        product != null &&
        product.actions.canAddToCart &&
        product.sizeAvailability[_size] == true &&
        product.availableColors.any((color) => color.id == _color);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ListenableBuilder(
          listenable: widget.session,
          builder: (_, _) => _Gallery(
            slides: slides,
            styledCover: cover != null,
            favorite: widget.session.favorite(
              summary.id,
              initiallyFavorite: initiallyFavorite,
            ),
            onFavorite: () => widget.session.toggleFavorite(
              summary.id,
              initiallyFavorite: initiallyFavorite,
            ),
          ),
        ),
        DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [BoxShadow(color: Color(0x12000000), blurRadius: 5)],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(inset, 50, inset, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductTitle(
                  name: summary.name,
                  price: summary.price,
                  currency: summary.currency,
                ),
                const SizedBox(height: 9),
                if (product == null)
                  const _DetailsNote('Rating unavailable')
                else
                  Row(
                    children: [
                      _Stars(product.rating, size: 18),
                      const SizedBox(width: 5),
                      Transform.translate(
                        offset: const Offset(0, 2),
                        child: Text(
                          '(${product.ratingCount})',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 13),
                const Divider(),
                const SizedBox(height: 7),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: _Options(
                        label: 'Color',
                        children: [
                          if (product == null ||
                              product.availableColors.isEmpty)
                            const _DetailsNote('Unavailable'),
                          for (final color
                              in product?.availableColors ??
                                  const <ProductColor>[])
                            _ColorOption(
                              option: color,
                              selected: _color == color.id,
                              onTap: () => setState(() => _color = color.id),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: _Options(
                        label: 'Size',
                        children: [
                          if (product == null || product.availableSizes.isEmpty)
                            const _DetailsNote('Unavailable'),
                          for (final size
                              in product?.availableSizes ?? const <String>[])
                            _SizeOption(
                              size: size,
                              selected: _size == size,
                              onTap: product?.sizeAvailability[size] == true
                                  ? () => setState(() => _size = size)
                                  : null,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Divider(),
                _SectionTitle(
                  'Description',
                  expanded: _showDescription,
                  onTap: () =>
                      setState(() => _showDescription = !_showDescription),
                ),
                if (_showDescription) ...[
                  const SizedBox(height: 19),
                  if (loading)
                    const LinearProgressIndicator(
                      semanticsLabel: 'Loading product details',
                    )
                  else if (widget.snapshot.error
                      case final CatalogFailure failure
                      when failure.error == CatalogError.unavailable)
                    const _DetailsNote(
                      'No description was provided for this product.',
                    )
                  else if (widget.snapshot.hasError) ...[
                    _DetailsNote(catalogErrorMessage(widget.snapshot.error)),
                    TextButton(
                      onPressed: widget.onRetry,
                      child: const Text('Try again'),
                    ),
                  ] else if (description.isEmpty)
                    const _DetailsNote(
                      'No description was provided for this product.',
                    )
                  else
                    Text.rich(
                      TextSpan(
                        text: description,
                        children: [
                          if (canExpand) ...[
                            const TextSpan(text: '  '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: InkWell(
                                onTap: () => setState(
                                  () => _fullDescription = !_fullDescription,
                                ),
                                child: Text(
                                  _fullDescription ? 'Show less' : 'Read more',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: accent,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.65,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                ],
                const SizedBox(height: 26),
                _SectionTitle(
                  'Reviews',
                  expanded: _showReviews,
                  onTap: () => setState(() => _showReviews = !_showReviews),
                ),
                if (_showReviews && product == null && !loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: _DetailsNote(
                      'Reviews unavailable for this product.',
                    ),
                  ),
                if (_showReviews && product != null) ...[
                  _Ratings(product: product),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.reviewCount + localReviews.length} Reviews',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _writeReview,
                        iconAlignment: IconAlignment.end,
                        icon: const StoreIcon(
                          StoreGlyph.pencil,
                          width: 16,
                          height: 16,
                          color: Color(0xFFC5C5C9),
                        ),
                        label: const Text('WRITE A REVIEW'),
                        style: TextButton.styleFrom(
                          foregroundColor: muted,
                          padding: EdgeInsets.zero,
                          textStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (final review in [...localReviews, ...product.reviews])
                    _ReviewTile(review: review),
                ],
                const SizedBox(height: 5),
                _SectionTitle(
                  'Similar Product',
                  expanded: _showSimilar,
                  onTap: () => setState(() => _showSimilar = !_showSimilar),
                ),
              ],
            ),
          ),
        ),
        if (_showSimilar && product == null && !loading)
          const Padding(
            padding: EdgeInsets.fromLTRB(inset, 16, inset, 0),
            child: _DetailsNote('Similar products unavailable.'),
          ),
        if (_showSimilar &&
            product != null &&
            product.similarProducts.isNotEmpty) ...[
          const SizedBox(height: 31),
          ProductRail(
            products: product.similarProducts,
            onProduct: widget.onSimilar,
          ),
        ],
        const SizedBox(height: 39),
        Material(
          color: const Color(0xFF343434),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: InkWell(
              onTap: _addToCart,
              child: SizedBox(
                height: 77,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: canAdd ? 1 : .54,
                      child: const StoreIcon(
                        StoreGlyph.bag,
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      product?.actions.addToCartLabel ?? 'Add To Cart',
                      style: TextStyle(
                        color: canAdd ? Colors.white : Colors.white54,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailsNote extends StatelessWidget {
  const _DetailsNote(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 12, color: muted));
}

class _Gallery extends StatefulWidget {
  const _Gallery({
    required this.slides,
    required this.styledCover,
    this.favorite = false,
    this.onFavorite,
  });
  final List<Widget> slides;
  final bool styledCover;
  final bool favorite;
  final VoidCallback? onFavorite;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _active = 0;
  int get _pageCount => widget.slides.length;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 406,
    child: Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: _pageCount,
          onPageChanged: (index) => setState(() => _active = index),
          itemBuilder: (_, index) => widget.slides[index],
        ),
        Positioned(
          top: (MediaQuery.paddingOf(context).top + 16).clamp(
            61.0,
            double.infinity,
          ),
          left: inset,
          right: inset,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _GalleryButton(
                tooltip: 'Back',
                icon: const StoreIcon(
                  StoreGlyph.back,
                  width: 8,
                  height: 14,
                  color: Color(0xFF1D3557),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              if (widget.onFavorite != null)
                _GalleryButton(
                  tooltip: widget.favorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  icon: Icon(
                    widget.favorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: const Color(0xFFFF6E6E),
                    size: 22,
                  ),
                  onPressed: widget.onFavorite!,
                ),
            ],
          ),
        ),
        if (_pageCount > 1)
          Positioned(
            left: 5,
            right: 0,
            bottom: 12,
            child: Center(
              child: widget.styledCover && _active == 0
                  ? PageDots(count: _pageCount, active: _active)
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xCFFFFFFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: PageDots(count: _pageCount, active: _active),
                      ),
                    ),
            ),
          ),
      ],
    ),
  );
}

class _GalleryCover extends StatelessWidget {
  const _GalleryCover({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFFFFFCFA),
    child: Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.hardEdge,
      children: [
        const Positioned(
          top: 96,
          left: 81,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFFBF2ED),
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(dimension: 234),
          ),
        ),
        Positioned(
          top: 11.7,
          width: 355.3,
          height: 532.5,
          left: 19.8,
          child: Image.asset(asset, excludeFromSemantics: true),
        ),
      ],
    ),
  );
}

class _GalleryButton extends StatelessWidget {
  const _GalleryButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });
  final String tooltip;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 32,
    child: Material(
      shape: const CircleBorder(),
      color: Colors.white,
      elevation: 1,
      child: IconButton(
        tooltip: tooltip,
        icon: icon,
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      ),
    ),
  );
}

class _ProductTitle extends StatelessWidget {
  const _ProductTitle({
    required this.name,
    required this.price,
    required this.currency,
  });
  final String name;
  final double price;
  final String currency;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          name,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        priceLabel(price, currency),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _Options extends StatelessWidget {
  const _Options({required this.label, required this.children});
  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: muted, fontSize: 13)),
      const SizedBox(height: 12),
      Wrap(spacing: 7, runSpacing: 7, children: children),
    ],
  );
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.option,
    required this.selected,
    required this.onTap,
  });
  final ProductColor option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hex = int.tryParse(option.value.replaceFirst('#', ''), radix: 16);
    return Tooltip(
      message: option.name,
      child: Semantics(
        label: option.name,
        button: true,
        selected: selected,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 31,
            height: 31,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x30000000),
                        offset: Offset(0, 3),
                        blurRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: switch (hex) {
                  0xE9C5AC => const Color(0xFFE7C0A7),
                  0x000000 => const Color(0xFF050302),
                  0xEF6262 => const Color(0xFFEE6969),
                  null => soft,
                  _ => Color(0xFF000000 | hex),
                },
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SizeOption extends StatelessWidget {
  const _SizeOption({required this.size, required this.selected, this.onTap});
  final String size;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    enabled: onTap != null,
    label: onTap == null ? 'Size $size unavailable' : 'Size $size',
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 33,
        height: 33,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? const Color(0xFF515151) : const Color(0xFFFAFAFA),
        ),
        child: Text(
          size,
          style: TextStyle(
            fontSize: 12,
            color: selected
                ? Colors.white
                : onTap == null
                ? Colors.black38
                : ink,
          ),
        ),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(
    this.title, {
    required this.expanded,
    required this.onTap,
  });
  final String title;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Semantics(
        expanded: expanded,
        button: true,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: RotatedBox(
                    quarterTurns: expanded ? 0 : 3,
                    child: const StoreIcon(
                      StoreGlyph.chevron,
                      width: 13.5,
                      height: 8.5,
                      color: Color(0xFF343434),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const Divider(height: 1),
    ],
  );
}

class _Stars extends StatelessWidget {
  const _Stars(this.rating, {required this.size});
  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$rating out of 5 stars',
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Padding(
          padding: EdgeInsets.only(
            right: index == 4
                ? 0
                : size >= 18
                ? 7
                : 5,
          ),
          child: rating >= index + .75
              ? StoreIcon(
                  StoreGlyph.star,
                  width: size,
                  height: size * 8 / 9,
                  color: accent,
                )
              : Icon(
                  rating > index + .25 ? Icons.star_half : Icons.star_border,
                  color: accent,
                  size: size,
                ),
        ),
      ),
    ),
  );
}

class _Ratings extends StatelessWidget {
  const _Ratings({required this.product});
  final ProductDetails product;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Column(
      children: [
        Row(
          children: [
            Text(
              product.rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'OUT OF 5',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Stars(product.rating, size: 16),
                Text(
                  '${product.ratingCount} ratings',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final band in product.ratingBreakdown)
          SizedBox(
            height: 29,
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                  child: Text(
                    '${band.stars}',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                const StoreIcon(
                  StoreGlyph.star,
                  width: 12,
                  height: 10.7,
                  color: accent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (band.percentage / 100).clamp(0.0, 1.0),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(4),
                    color: accent,
                    backgroundColor: dividerColor,
                    semanticsLabel: '${band.stars} star ratings',
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${band.percentage}%',
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 21, bottom: 19),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipOval(
              child: SizedBox.square(
                dimension: 36,
                child: review.avatarUrl.isEmpty
                    ? const ColoredBox(
                        color: soft,
                        child: Icon(Icons.person_outline),
                      )
                    : CatalogPhoto(
                        review.avatarUrl,
                        asset: CatalogPhotos.of(
                          context,
                        ).assetFor(PhotoSlot.review, review.id),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.author,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _Stars(review.rating, size: 10),
                ],
              ),
            ),
            Text(
              review.createdAtLabel,
              style: const TextStyle(
                color: muted,
                fontSize: 10,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          review.text,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w300,
            height: 1.55,
          ),
        ),
      ],
    ),
  );
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog();

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _text = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Write a review'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          children: [
            for (var stars = 1; stars <= 5; stars++)
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: '$stars stars',
                onPressed: () => setState(() => _rating = stars),
                icon: Icon(
                  stars <= _rating ? Icons.star : Icons.star_border,
                  color: accent,
                ),
              ),
          ],
        ),
        TextField(
          controller: _text,
          maxLength: 500,
          maxLines: 3,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(labelText: 'Your review'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _text.text.trim().isEmpty
            ? null
            : () => Navigator.pop(
                context,
                Review(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  author: 'You',
                  avatarUrl: '',
                  rating: _rating.toDouble(),
                  createdAtLabel: 'Now',
                  text: _text.text.trim(),
                ),
              ),
        child: const Text('Save'),
      ),
    ],
  );
}
