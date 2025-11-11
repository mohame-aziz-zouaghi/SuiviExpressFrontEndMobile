import 'package:flutter/material.dart';
import 'package:suiviexpress_app/data/models/product_model.dart';
import 'package:suiviexpress_app/data/services/product_service.dart';
import 'package:suiviexpress_app/database/database_helper.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({super.key});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _thumbnailUrlController = TextEditingController();

  bool _available = true;
  bool _visible = true;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'ELECTRONICS',
    'CLOTHING',
    'FOOD',
    'BEAUTY',
    'HOME',
    'SPORTS',
    'TOYS',
    'AUTOMOTIVE',
    'BOOKS',
    'PETS',
    'OFFICE',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

Future<void> _submitProduct() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isSubmitting = true);

  // Create product object
  final newProduct = Product(
    name: _nameController.text.trim(),
    description: _descriptionController.text.trim(),
    brand: _brandController.text.trim(),
    category: _categoryController.text.trim(),
    price: double.tryParse(_priceController.text.trim()) ?? 0,
    discount: double.tryParse(_discountController.text.trim()) ?? 0,
    stockQuantity: int.tryParse(_stockController.text.trim()) ?? 0,
    available: _available,
    imageUrl: _imageUrlController.text.trim(),
    thumbnailUrl: _thumbnailUrlController.text.trim(),
    averageRating: 0,
    reviewCount: 0,
    visible: _visible,
    synced: false, // mark as unsynced initially
  );

  try {
    // Try to create online
    await _productService.createProduct(newProduct);

    // If successful, mark as synced and optionally store locally too
    newProduct.synced = true;
    await DatabaseHelper().insertProduct(newProduct);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Product created successfully online!")),
    );
  } catch (e) {
    // Network error / offline -> store locally
    await DatabaseHelper().insertProduct(newProduct);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No connection. Product saved locally.")),
    );
  } finally {
    setState(() => _isSubmitting = false);
    Navigator.pop(context); // go back to products page
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Product"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, "Name"),
              _buildTextField(_descriptionController, "Description", maxLines: 3),
              _buildTextField(_brandController, "Brand"),
              _buildCategoryDropdown(),
              _buildTextField(_priceController, "Price", isNumber: true),
              _buildTextField(_discountController, "Discount", isNumber: true),
              _buildTextField(_stockController, "Stock Quantity", isNumber: true),
              _buildTextField(_imageUrlController, "Image URL"),
              _buildTextField(_thumbnailUrlController, "Thumbnail URL"),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Available:"),
                  Switch(
                    value: _available,
                    onChanged: (val) => setState(() => _available = val),
                  ),
                  const SizedBox(width: 16),
                  const Text("Visible:"),
                  Switch(
                    value: _visible,
                    onChanged: (val) => setState(() => _visible = val),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Create Product",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Please enter $label";
          }
          if (isNumber && double.tryParse(value.trim()) == null) {
            return "$label must be a number";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: null,
        decoration: InputDecoration(
          labelText: "Category",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        items: _categories
            .map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                ))
            .toList(),
        onChanged: (value) {
          if (value != null) _categoryController.text = value;
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Please select a category";
          }
          return null;
        },
      ),
    );
  }
}
