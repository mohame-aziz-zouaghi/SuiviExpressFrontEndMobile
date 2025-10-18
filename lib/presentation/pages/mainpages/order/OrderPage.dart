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
    double totalPrice =
        quantity * (widget.product.price - widget.product.discount);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order Product",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.product.thumbnailUrl,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 100,
                          width: 100,
                          color: Colors.indigo.shade100,
                          child: const Icon(Icons.image, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("Brand: ${widget.product.brand}"),
                          Text("Category: ${widget.product.category}"),
                          const SizedBox(height: 4),
// Price & Discount in Order Page
Row(
  children: [
    if (widget.product.discount > 0)
      Text(
        "\$${widget.product.price.toStringAsFixed(2)}",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          decoration: TextDecoration.lineThrough,
        ),
      ),
    if (widget.product.discount > 0) const SizedBox(width: 8),
    Text(
      "  \$${(widget.product.price - widget.product.discount).toStringAsFixed(2)}",
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.indigo,
      ),
    ),
  ],
),

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.product.description,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quantity Selector
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
                const Spacer(),
                Text(
                  "Total: \$${totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: quantity > 0
                    ? () {
                        // Add logic to add to cart
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Added $quantity x ${widget.product.name} to cart",
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Confirm Order",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
