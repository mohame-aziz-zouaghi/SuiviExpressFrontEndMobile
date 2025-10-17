import 'package:flutter/material.dart';
import 'package:suiviexpress_app/data/models/product_model.dart';
import 'package:suiviexpress_app/data/services/product_service.dart';
import 'package:suiviexpress_app/presentation/pages/mainpages/product/PoductDetailsPage.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _productsFuture;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  final ScrollController _scrollController = ScrollController();

  // Filters
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  String? _selectedCategory;

  // Collapse state
  bool _filtersExpanded = false;

  // Example categories
  final List<String> _categories = [
    'ELECTRONICS',
    'FASHION',
    'HOME',
    'TOYS',
    'SPORTS'
  ];

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getVisibleProducts();
    _productsFuture.then((value) {
      setState(() {
        _allProducts = value;
        _filteredProducts = List.from(_allProducts);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    double? minPrice = double.tryParse(_minPriceController.text);
    double? maxPrice = double.tryParse(_maxPriceController.text);
    String search = _searchController.text.toLowerCase();

    setState(() {
      _filteredProducts = _allProducts.where((product) {
        bool matchesCategory = _selectedCategory == null ||
            product.category.toUpperCase() == _selectedCategory;
        bool matchesMin = minPrice == null || product.price >= minPrice;
        bool matchesMax = maxPrice == null || product.price <= maxPrice;
        bool matchesSearch = product.name.toLowerCase().contains(search);
        return matchesCategory && matchesMin && matchesMax && matchesSearch;
      }).toList();
    });
  }

  void _resetFilters() {
    _searchController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    _selectedCategory = null;
    setState(() {
      _filteredProducts = List.from(_allProducts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Products",    style: TextStyle(color: Colors.white), // <-- white text
),
        
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ---------------- Search Bar ----------------
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search products...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) => _applyFilters(),
                ),
                const SizedBox(height: 8),

                // Collapsible Filter Header
                GestureDetector(
                  onTap: () {
                    setState(() => _filtersExpanded = !_filtersExpanded);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filters",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Icon(
                          _filtersExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.indigo,
                        ),
                      ],
                    ),
                  ),
                ),

                // ---------------- Collapsible Filter Panel ----------------
                if (_filtersExpanded) ...[
                  const SizedBox(height: 8),
                  Column(
                    children: [
                      Row(
                        children: [
                          // Category Dropdown
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              hint: const Text("Category"),
                              items: _categories
                                  .map((cat) => DropdownMenuItem(
                                        value: cat,
                                        child: Text(cat),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _selectedCategory = value);
                                _applyFilters();
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Min Price
                          Expanded(
                            child: TextField(
                              controller: _minPriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Min Price",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                              ),
                              onChanged: (_) => _applyFilters(),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Max Price
                          Expanded(
                            child: TextField(
                              controller: _maxPriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Max Price",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 0),
                              ),
                              onChanged: (_) => _applyFilters(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _resetFilters,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.indigo),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("Reset Filters"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ---------------- Products Grid ----------------
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(child: Text("No products found"))
                : GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return _ProductCard(
                        product: product,
                        onViewDetails: () async {
                          final offset = _scrollController.offset;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailsPage(product: product),
                            ),
                          );
                          _scrollController.jumpTo(offset);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onViewDetails;

  const _ProductCard({
    required this.product,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.network(
              product.imageUrl,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.indigo.shade100,
                height: 140,
                child: const Center(
                  child: Icon(Icons.image_not_supported,
                      size: 50, color: Colors.indigo),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "\$${product.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                            color: Colors.indigo, fontWeight: FontWeight.bold),
                      ),
                      if (product.discount > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          "-\$${product.discount.toStringAsFixed(2)}",
                          style:
                              const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "${product.averageRating.toStringAsFixed(1)} (${product.reviewCount})",
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onViewDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Show Details",
                        style: TextStyle(fontWeight: FontWeight.bold,color:Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
