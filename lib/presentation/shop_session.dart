import 'package:flutter/foundation.dart';

import '../domain/catalog.dart';

class CartLine {
  const CartLine(this.product, this.color, this.size);

  final ProductDetails product;
  final String color;
  final String size;
}

class ShopSession extends ChangeNotifier {
  final _favorites = <String, bool>{};
  final _cart = <CartLine>[];
  final _reviews = <String, List<Review>>{};

  List<CartLine> get cart => List.unmodifiable(_cart);

  List<Review> reviewsFor(String productId) =>
      List.unmodifiable(_reviews[productId] ?? const <Review>[]);

  void addReview(String productId, Review review) {
    (_reviews[productId] ??= []).insert(0, review);
    notifyListeners();
  }

  bool favorite(String productId, {bool initiallyFavorite = false}) =>
      _favorites[productId] ?? initiallyFavorite;

  void toggleFavorite(String productId, {bool initiallyFavorite = false}) {
    _favorites[productId] = !favorite(
      productId,
      initiallyFavorite: initiallyFavorite,
    );
    notifyListeners();
  }

  void add(CartLine line) {
    _cart.add(line);
    notifyListeners();
  }

  void remove(CartLine line) {
    _cart.remove(line);
    notifyListeners();
  }
}
