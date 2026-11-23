import 'package:json_annotation/json_annotation.dart';
import '../domain/catalog.dart';

part 'catalog_dtos.g.dart';

@JsonSerializable(checked: true, explicitToJson: true)
class CategoryDto {
  const CategoryDto({
    required this.id,
    required this.name,
    required this.selected,
    required this.iconUrl,
  });

  final String id;
  final String name;
  final bool selected;
  final String iconUrl;

  factory CategoryDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryDtoToJson(this);

  Category toEntity() =>
      Category(id: id, name: name, selected: selected, iconUrl: iconUrl);
}

@JsonSerializable(checked: true, explicitToJson: true)
class BannerDto {
  const BannerDto({
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

  factory BannerDto.fromJson(Map<String, dynamic> json) =>
      _$BannerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BannerDtoToJson(this);

  Banner toEntity() => Banner(
    id: id,
    title: title,
    imageUrl: imageUrl,
    action: action,
    slides: slides,
    activeSlide: activeSlide,
  );
}

@JsonSerializable(checked: true, explicitToJson: true)
class ProductSummaryDto {
  const ProductSummaryDto({
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

  factory ProductSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ProductSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProductSummaryDtoToJson(this);

  ProductSummary toEntity() => ProductSummary(
    id: id,
    name: name,
    price: price,
    currency: currency,
    imageUrl: imageUrl,
  );
}

@JsonSerializable(checked: true, explicitToJson: true)
class CollectionDto {
  const CollectionDto({
    this.id,
    required this.label,
    required this.title,
    required this.imageUrl,
  });

  @JsonKey(includeIfNull: false)
  final String? id;
  final String label;
  final String title;
  final String imageUrl;

  factory CollectionDto.fromJson(Map<String, dynamic> json) =>
      _$CollectionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionDtoToJson(this);

  Collection toEntity() =>
      Collection(id: id, label: label, title: title, imageUrl: imageUrl);
}

@JsonSerializable(checked: true, explicitToJson: true)
class CategoryPromoDto {
  const CategoryPromoDto({
    required this.id,
    required this.category,
    required this.title,
    required this.imageUrl,
  });

  final String id;
  final String category;
  final String title;
  final String imageUrl;

  factory CategoryPromoDto.fromJson(Map<String, dynamic> json) =>
      _$CategoryPromoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryPromoDtoToJson(this);

  CategoryPromo toEntity() => CategoryPromo(
    id: id,
    category: category,
    title: title,
    imageUrl: imageUrl,
  );
}

@JsonSerializable(checked: true, explicitToJson: true)
class FeedDto {
  const FeedDto({
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
  final List<CategoryDto> categories;
  final BannerDto heroBanner;
  final List<ProductSummaryDto> featureProducts;
  final CollectionDto newCollection;
  final List<ProductSummaryDto> recommended;
  final List<CollectionDto> topCollections;
  final List<CategoryPromoDto> categoryPromos;

  factory FeedDto.fromJson(Map<String, dynamic> json) =>
      _$FeedDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FeedDtoToJson(this);

  Feed toEntity() => Feed(
    storeName: storeName,
    categories: List.unmodifiable(categories.map((item) => item.toEntity())),
    heroBanner: heroBanner.toEntity(),
    featureProducts: List.unmodifiable(
      featureProducts.map((item) => item.toEntity()),
    ),
    newCollection: newCollection.toEntity(),
    recommended: List.unmodifiable(recommended.map((item) => item.toEntity())),
    topCollections: List.unmodifiable(
      topCollections.map((item) => item.toEntity()),
    ),
    categoryPromos: List.unmodifiable(
      categoryPromos.map((item) => item.toEntity()),
    ),
  );
}

@JsonSerializable(checked: true, explicitToJson: true)
class ProductColorDto {
  const ProductColorDto({
    required this.id,
    required this.name,
    required this.value,
  });

  final String id;
  final String name;
  final String value;

  factory ProductColorDto.fromJson(Map<String, dynamic> json) =>
      _$ProductColorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProductColorDtoToJson(this);

  ProductColor toEntity() => ProductColor(id: id, name: name, value: value);
}

@JsonSerializable(checked: true, explicitToJson: true)
class RatingBandDto {
  const RatingBandDto({required this.stars, required this.percentage});

  final int stars;
  final int percentage;

  factory RatingBandDto.fromJson(Map<String, dynamic> json) =>
      _$RatingBandDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RatingBandDtoToJson(this);

  RatingBand toEntity() => RatingBand(stars: stars, percentage: percentage);
}

@JsonSerializable(checked: true, explicitToJson: true)
class ReviewDto {
  const ReviewDto({
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

  factory ReviewDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewDtoToJson(this);

  Review toEntity() => Review(
    id: id,
    author: author,
    avatarUrl: avatarUrl,
    rating: rating,
    createdAtLabel: createdAtLabel,
    text: text,
  );
}

@JsonSerializable(checked: true, explicitToJson: true)
class ProductActionsDto {
  const ProductActionsDto({
    required this.isFavorite,
    required this.canAddToCart,
    required this.addToCartLabel,
  });

  final bool isFavorite;
  final bool canAddToCart;
  final String addToCartLabel;

  factory ProductActionsDto.fromJson(Map<String, dynamic> json) =>
      _$ProductActionsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProductActionsDtoToJson(this);

  ProductActions toEntity() => ProductActions(
    isFavorite: isFavorite,
    canAddToCart: canAddToCart,
    addToCartLabel: addToCartLabel,
  );
}

@JsonSerializable(checked: true, explicitToJson: true)
class ProductDetailsDto {
  const ProductDetailsDto({
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
  final List<ProductColorDto> availableColors;
  final String selectedColor;
  final List<String> availableSizes;
  final String selectedSize;
  final Map<String, bool> sizeAvailability;
  final List<RatingBandDto> ratingBreakdown;
  final List<ReviewDto> reviews;
  final List<ProductSummaryDto> similarProducts;
  final ProductActionsDto actions;

  factory ProductDetailsDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDetailsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDetailsDtoToJson(this);

  ProductDetails toEntity() => ProductDetails(
    id: id,
    name: name,
    price: price,
    currency: currency,
    mainImageUrl: mainImageUrl,
    galleryImageUrls: List.unmodifiable(galleryImageUrls),
    rating: rating,
    ratingCount: ratingCount,
    reviewCount: reviewCount,
    description: description,
    descriptionExpanded: descriptionExpanded,
    availableColors: List.unmodifiable(
      availableColors.map((item) => item.toEntity()),
    ),
    selectedColor: selectedColor,
    availableSizes: List.unmodifiable(availableSizes),
    selectedSize: selectedSize,
    sizeAvailability: Map.unmodifiable(sizeAvailability),
    ratingBreakdown: List.unmodifiable(
      ratingBreakdown.map((item) => item.toEntity()),
    ),
    reviews: List.unmodifiable(reviews.map((item) => item.toEntity())),
    similarProducts: List.unmodifiable(
      similarProducts.map((item) => item.toEntity()),
    ),
    actions: actions.toEntity(),
  );
}
