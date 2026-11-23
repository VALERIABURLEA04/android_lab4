class Category {
  const Category({
    required this.id,
    required this.name,
    required this.selected,
    required this.iconUrl,
  });

  final String id;
  final String name;
  final bool selected;
  final String iconUrl;
}

class Banner {
  const Banner({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.action,
    required this.slides,
    required this.activeSlide,
  });

  final String id;
  final String title;
  final String imageUrl;
  final String action;
  final int slides;
  final int activeSlide;
}

class ProductSummary {
  const ProductSummary({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final double price;
  final String currency;
  final String imageUrl;
}

class Collection {
  const Collection({
    this.id,
    required this.label,
    required this.title,
    required this.imageUrl,
  });

  final String? id;
  final String label;
  final String title;
  final String imageUrl;
}

class CategoryPromo {
  const CategoryPromo({
    required this.id,
    required this.category,
    required this.title,
    required this.imageUrl,
  });

  final String id;
  final String category;
  final String title;
  final String imageUrl;
}

class Feed {
  const Feed({
    required this.storeName,
    required this.categories,
    required this.heroBanner,
    required this.featureProducts,
    required this.newCollection,
    required this.recommended,
    required this.topCollections,
    required this.categoryPromos,
  });

  final String storeName;
  final List<Category> categories;
  final Banner heroBanner;
  final List<ProductSummary> featureProducts;
  final Collection newCollection;
  final List<ProductSummary> recommended;
  final List<Collection> topCollections;
  final List<CategoryPromo> categoryPromos;
}

class ProductColor {
  const ProductColor({
    required this.id,
    required this.name,
    required this.value,
  });

  final String id;
  final String name;
  final String value;
}

class RatingBand {
  const RatingBand({required this.stars, required this.percentage});

  final int stars;
  final int percentage;
}

class Review {
  const Review({
    required this.id,
    required this.author,
    required this.avatarUrl,
    required this.rating,
    required this.createdAtLabel,
    required this.text,
  });

  final String id;
  final String author;
  final String avatarUrl;
  final double rating;
  final String createdAtLabel;
  final String text;
}

class ProductActions {
  const ProductActions({
    required this.isFavorite,
    required this.canAddToCart,
    required this.addToCartLabel,
  });

  final bool isFavorite;
  final bool canAddToCart;
  final String addToCartLabel;
}

class ProductDetails {
  const ProductDetails({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.mainImageUrl,
    required this.galleryImageUrls,
    required this.rating,
    required this.ratingCount,
    required this.reviewCount,
    required this.description,
    required this.descriptionExpanded,
    required this.availableColors,
    required this.selectedColor,
    required this.availableSizes,
    required this.selectedSize,
    required this.sizeAvailability,
    required this.ratingBreakdown,
    required this.reviews,
    required this.similarProducts,
    required this.actions,
  });

  final String id;
  final String name;
  final double price;
  final String currency;
  final String mainImageUrl;
  final List<String> galleryImageUrls;
  final double rating;
  final int ratingCount;
  final int reviewCount;
  final String description;
  final bool descriptionExpanded;
  final List<ProductColor> availableColors;
  final String selectedColor;
  final List<String> availableSizes;
  final String selectedSize;
  final Map<String, bool> sizeAvailability;
  final List<RatingBand> ratingBreakdown;
  final List<Review> reviews;
  final List<ProductSummary> similarProducts;
  final ProductActions actions;
}
