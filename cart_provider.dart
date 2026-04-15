import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount {
    int count = 0;
    for (final item in _items) {
      count += item.qty;
    }
    return count;
  }

  double get total {
    double sum = 0;
    for (final item in _items) {
      sum += item.price * item.qty;
    }
    return sum;
  }

  void addItem(CartItem item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index].qty += 1;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void increaseQty(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    _items[index].qty += 1;
    notifyListeners();
  }

  void decreaseQty(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;

    if (_items[index].qty > 1) {
      _items[index].qty -= 1;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}