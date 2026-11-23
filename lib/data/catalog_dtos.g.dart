// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryDto _$CategoryDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CategoryDto', json, ($checkedConvert) {
      final val = CategoryDto(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        selected: $checkedConvert('selected', (v) => v as bool),
        iconUrl: $checkedConvert('iconUrl', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$CategoryDtoToJson(CategoryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'selected': instance.selected,
      'iconUrl': instance.iconUrl,
    };

BannerDto _$BannerDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BannerDto', json, ($checkedConvert) {
      final val = BannerDto(
        id: $checkedConvert('id', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        imageUrl: $checkedConvert('imageUrl', (v) => v as String),
        action: $checkedConvert('action', (v) => v as String),
        slides: $checkedConvert('slides', (v) => (v as num).toInt()),
        activeSlide: $checkedConvert('activeSlide', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$BannerDtoToJson(BannerDto instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'imageUrl': instance.imageUrl,
  'action': instance.action,
  'slides': instance.slides,
  'activeSlide': instance.activeSlide,
};

ProductSummaryDto _$ProductSummaryDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProductSummaryDto', json, ($checkedConvert) {
      final val = ProductSummaryDto(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        price: $checkedConvert('price', (v) => (v as num).toDouble()),
        currency: $checkedConvert('currency', (v) => v as String),
        imageUrl: $checkedConvert('imageUrl', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ProductSummaryDtoToJson(ProductSummaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'currency': instance.currency,
      'imageUrl': instance.imageUrl,
    };

CollectionDto _$CollectionDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CollectionDto', json, ($checkedConvert) {
      final val = CollectionDto(
        id: $checkedConvert('id', (v) => v as String?),
        label: $checkedConvert('label', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        imageUrl: $checkedConvert('imageUrl', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$CollectionDtoToJson(CollectionDto instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'label': instance.label,
      'title': instance.title,
      'imageUrl': instance.imageUrl,
    };

CategoryPromoDto _$CategoryPromoDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CategoryPromoDto', json, ($checkedConvert) {
      final val = CategoryPromoDto(
        id: $checkedConvert('id', (v) => v as String),
        category: $checkedConvert('category', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        imageUrl: $checkedConvert('imageUrl', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$CategoryPromoDtoToJson(CategoryPromoDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'title': instance.title,
      'imageUrl': instance.imageUrl,
    };

FeedDto _$FeedDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FeedDto', json, ($checkedConvert) {
      final val = FeedDto(
        storeName: $checkedConvert('storeName', (v) => v as String),
        categories: $checkedConvert(
          'categories',
          (v) => (v as List<dynamic>)
              .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        heroBanner: $checkedConvert(
          'heroBanner',
          (v) => BannerDto.fromJson(v as Map<String, dynamic>),
        ),
        featureProducts: $checkedConvert(
          'featureProducts',
          (v) => (v as List<dynamic>)
              .map((e) => ProductSummaryDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        newCollection: $checkedConvert(
          'newCollection',
          (v) => CollectionDto.fromJson(v as Map<String, dynamic>),
        ),
        recommended: $checkedConvert(
          'recommended',
          (v) => (v as List<dynamic>)
              .map((e) => ProductSummaryDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        topCollections: $checkedConvert(
          'topCollections',
          (v) => (v as List<dynamic>)
              .map((e) => CollectionDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        categoryPromos: $checkedConvert(
          'categoryPromos',
          (v) => (v as List<dynamic>)
              .map((e) => CategoryPromoDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$FeedDtoToJson(FeedDto instance) => <String, dynamic>{
  'storeName': instance.storeName,
  'categories': instance.categories.map((e) => e.toJson()).toList(),
  'heroBanner': instance.heroBanner.toJson(),
  'featureProducts': instance.featureProducts.map((e) => e.toJson()).toList(),
  'newCollection': instance.newCollection.toJson(),
  'recommended': instance.recommended.map((e) => e.toJson()).toList(),
  'topCollections': instance.topCollections.map((e) => e.toJson()).toList(),
  'categoryPromos': instance.categoryPromos.map((e) => e.toJson()).toList(),
};

ProductColorDto _$ProductColorDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProductColorDto', json, ($checkedConvert) {
      final val = ProductColorDto(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        value: $checkedConvert('value', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ProductColorDtoToJson(ProductColorDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'value': instance.value,
    };

RatingBandDto _$RatingBandDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RatingBandDto', json, ($checkedConvert) {
      final val = RatingBandDto(
        stars: $checkedConvert('stars', (v) => (v as num).toInt()),
        percentage: $checkedConvert('percentage', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$RatingBandDtoToJson(RatingBandDto instance) =>
    <String, dynamic>{
      'stars': instance.stars,
      'percentage': instance.percentage,
    };

ReviewDto _$ReviewDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReviewDto', json, ($checkedConvert) {
      final val = ReviewDto(
        id: $checkedConvert('id', (v) => v as String),
        author: $checkedConvert('author', (v) => v as String),
        avatarUrl: $checkedConvert('avatarUrl', (v) => v as String),
        rating: $checkedConvert('rating', (v) => (v as num).toDouble()),
        createdAtLabel: $checkedConvert('createdAtLabel', (v) => v as String),
        text: $checkedConvert('text', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ReviewDtoToJson(ReviewDto instance) => <String, dynamic>{
  'id': instance.id,
  'author': instance.author,
  'avatarUrl': instance.avatarUrl,
  'rating': instance.rating,
  'createdAtLabel': instance.createdAtLabel,
  'text': instance.text,
};

ProductActionsDto _$ProductActionsDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProductActionsDto', json, ($checkedConvert) {
      final val = ProductActionsDto(
        isFavorite: $checkedConvert('isFavorite', (v) => v as bool),
        canAddToCart: $checkedConvert('canAddToCart', (v) => v as bool),
        addToCartLabel: $checkedConvert('addToCartLabel', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ProductActionsDtoToJson(ProductActionsDto instance) =>
    <String, dynamic>{
      'isFavorite': instance.isFavorite,
      'canAddToCart': instance.canAddToCart,
      'addToCartLabel': instance.addToCartLabel,
    };

ProductDetailsDto _$ProductDetailsDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProductDetailsDto', json, ($checkedConvert) {
      final val = ProductDetailsDto(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        price: $checkedConvert('price', (v) => (v as num).toDouble()),
        currency: $checkedConvert('currency', (v) => v as String),
        mainImageUrl: $checkedConvert('mainImageUrl', (v) => v as String),
        galleryImageUrls: $checkedConvert(
          'galleryImageUrls',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        rating: $checkedConvert('rating', (v) => (v as num).toDouble()),
        ratingCount: $checkedConvert('ratingCount', (v) => (v as num).toInt()),
        reviewCount: $checkedConvert('reviewCount', (v) => (v as num).toInt()),
        description: $checkedConvert('description', (v) => v as String),
        descriptionExpanded: $checkedConvert(
          'descriptionExpanded',
          (v) => v as bool,
        ),
        availableColors: $checkedConvert(
          'availableColors',
          (v) => (v as List<dynamic>)
              .map((e) => ProductColorDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        selectedColor: $checkedConvert('selectedColor', (v) => v as String),
        availableSizes: $checkedConvert(
          'availableSizes',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        selectedSize: $checkedConvert('selectedSize', (v) => v as String),
        sizeAvailability: $checkedConvert(
          'sizeAvailability',
          (v) => Map<String, bool>.from(v as Map),
        ),
        ratingBreakdown: $checkedConvert(
          'ratingBreakdown',
          (v) => (v as List<dynamic>)
              .map((e) => RatingBandDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        reviews: $checkedConvert(
          'reviews',
          (v) => (v as List<dynamic>)
              .map((e) => ReviewDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        similarProducts: $checkedConvert(
          'similarProducts',
          (v) => (v as List<dynamic>)
              .map((e) => ProductSummaryDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        actions: $checkedConvert(
          'actions',
          (v) => ProductActionsDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ProductDetailsDtoToJson(
  ProductDetailsDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'currency': instance.currency,
  'mainImageUrl': instance.mainImageUrl,
  'galleryImageUrls': instance.galleryImageUrls,
  'rating': instance.rating,
  'ratingCount': instance.ratingCount,
  'reviewCount': instance.reviewCount,
  'description': instance.description,
  'descriptionExpanded': instance.descriptionExpanded,
  'availableColors': instance.availableColors.map((e) => e.toJson()).toList(),
  'selectedColor': instance.selectedColor,
  'availableSizes': instance.availableSizes,
  'selectedSize': instance.selectedSize,
  'sizeAvailability': instance.sizeAvailability,
  'ratingBreakdown': instance.ratingBreakdown.map((e) => e.toJson()).toList(),
  'reviews': instance.reviews.map((e) => e.toJson()).toList(),
  'similarProducts': instance.similarProducts.map((e) => e.toJson()).toList(),
  'actions': instance.actions.toJson(),
};
