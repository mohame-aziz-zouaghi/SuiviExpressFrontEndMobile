import 'package:flutter/material.dart';
import 'package:suiviexpress_app/data/models/product_model.dart';

class OrderPage extends StatefulWidget {
  final Product product;
  const OrderPage({required this.product, super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Product",    style: TextStyle(color: Colors.white), // <-- white text
),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.product.name,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text("Available Stock: ${widget.product.stockQuantity}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Quantity:", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: quantity > 1
                      ? () => setState(() => quantity--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Text("$quantity", style: const TextStyle(fontSize: 16)),
                IconButton(
                  onPressed: quantity < widget.product.stockQuantity
                      ? () => setState(() => quantity++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: quantity > 0
                    ? () {
                        // Navigate to cart page or add logic to add to cart
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "Added $quantity x ${widget.product.name} to cart")),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text(
                  "Confirm Order",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16,color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
