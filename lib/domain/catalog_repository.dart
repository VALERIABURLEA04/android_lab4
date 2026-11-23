import 'catalog.dart';

abstract interface class CatalogRepository {
  Future<Feed> getFeed();
  Future<ProductDetails> getDetails(String productId);
}

class GetFeed {
  const GetFeed(this._repository);

  final CatalogRepository _repository;

  Future<Feed> call() => _repository.getFeed();
}

class GetProductDetails {
  const GetProductDetails(this._repository);

  final CatalogRepository _repository;

  Future<ProductDetails> call(String productId) =>
      _repository.getDetails(productId);
}

enum CatalogError { timeout, network, server, invalidData, unavailable }

class CatalogFailure implements Exception {
  const CatalogFailure(this.error, {this.statusCode});

  final CatalogError error;
  final int? statusCode;
}
