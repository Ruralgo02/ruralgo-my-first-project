import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../screens/checkout_page.dart';

class CartPage extends StatelessWidget {
  static const routeName = '/cart';
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    final subtotal = cart.total;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: "Clear cart",
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmClear(context, cart),
            ),
        ],
      ),
      body: items.isEmpty
          ? _EmptyCart(
              onShop: () => Navigator.pop(context),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final item = items[i];

                      final name = item.name.toString();
                      final qty = item.qty as int;
                      final price = (item.price as num).toDouble();

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0x2200A082)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: const Color(0x1100A082),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.shopping_bag_outlined),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "₦${price.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        _QtyButton(
                                          icon: Icons.remove,
                                          onTap: () =>
                                              cart.decreaseQty(item.id),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "$qty",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        _QtyButton(
                                          icon: Icons.add,
                                          onTap: () =>
                                              cart.increaseQty(item.id),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          tooltip: "Remove item",
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              cart.removeItem(item.id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Column(
                    children: [
                      _rowLine(
                        "Subtotal",
                        "₦${subtotal.toStringAsFixed(0)}",
                        bold: true,
                      ),
                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: items.isEmpty
                              ? null
                              : () {
                                  final String orderId =
                                      "RG-${DateTime.now().millisecondsSinceEpoch}";
                                  Navigator.pushNamed(
                                    context,
                                    CheckoutPage.routeName,
                                    arguments: {
                                      "orderId": orderId,
                                      "orderType": "goods",
                                      "itemsTotal": subtotal.toInt(),
                                      "items": items
                                          .map((e) => {
                                                "id": e.id,
                                                "name": e.name,
                                                "price":
                                                    (e.price as num).toInt(),
                                                "qty": e.qty,
                                              })
                                          .toList(),
                                    },
                                  );
                                },
                          child: Text(
                            "Proceed to Checkout • ₦${subtotal.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Text(
                        "Delivery fee & service fee will show in checkout.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  static Widget _rowLine(String left, String right, {bool bold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        Text(
          right,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
            fontSize: bold ? 16 : 14,
          ),
        ),
      ],
    );
  }

  static Future<void> _confirmClear(BuildContext context, CartProvider cart) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Clear cart?"),
        content: const Text("This will remove all items from your cart."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(context);
            },
            child: const Text("Clear"),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x3300A082)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onShop;
  const _EmptyCart({required this.onShop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 70),
            const SizedBox(height: 10),
            const Text(
              "Your cart is empty",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              "Add items to your cart and checkout.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onShop,
                child: const Text(
                  "Start shopping",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}