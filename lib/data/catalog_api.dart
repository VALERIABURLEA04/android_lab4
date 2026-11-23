import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

import '../domain/catalog.dart';
import '../domain/catalog_repository.dart';
import 'catalog_dtos.dart';

class CatalogRemoteDataSource {
  CatalogRemoteDataSource(
    this._client, {
    this.timeout = const Duration(seconds: 60),
    String baseUrl = 'https://test-api-jlbn.onrender.com/lab2026/v1/',
  }) : _baseUri = Uri.parse(baseUrl);

  final http.Client _client;
  final Uri _baseUri;
  final Duration timeout;

  Future<FeedDto> fetchFeed() => _get('feed', FeedDto.fromJson);

  Future<ProductDetailsDto> fetchDetails() => _get(
    'feed/details',
    (json) =>
        ProductDetailsDto.fromJson(json['product'] as Map<String, dynamic>),
  );

  Future<T> _get<T>(String path, T Function(Map<String, dynamic>) parse) async {
    try {
      final response = await _client
          .get(_baseUri.resolve(path), headers: {'Accept': 'application/json'})
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CatalogFailure(
          CatalogError.server,
          statusCode: response.statusCode,
        );
      }
      return parse(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } on TimeoutException {
      throw const CatalogFailure(CatalogError.timeout);
    } on http.ClientException {
      throw const CatalogFailure(CatalogError.network);
    } on FormatException {
      throw const CatalogFailure(CatalogError.invalidData);
    } on CheckedFromJsonException {
      throw const CatalogFailure(CatalogError.invalidData);
    } on TypeError {
      throw const CatalogFailure(CatalogError.invalidData);
    }
  }
}

class RemoteCatalogRepository implements CatalogRepository {
  const RemoteCatalogRepository(this._remote);

  final CatalogRemoteDataSource _remote;

  @override
  Future<Feed> getFeed() async => (await _remote.fetchFeed()).toEntity();

  @override
  Future<ProductDetails> getDetails(String productId) async {
    final details = await _remote.fetchDetails();
    if (details.id != productId) {
      throw const CatalogFailure(CatalogError.unavailable);
    }
    return details.toEntity();
  }
}
