import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scanme_app/services/database_helper.dart';

// ... other imports

// In ProductResultScreen, we need to save the result.
// I will rewrite ProductResultScreen to incorporate the save logic.

import 'package:flutter_animate/flutter_animate.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:scanme_app/services/product_service.dart';

class ProductResultScreen extends StatefulWidget {
  final String barcode;
  
  const ProductResultScreen({super.key, required this.barcode});

  @override
  State<ProductResultScreen> createState() => _ProductResultScreenState();
}

class _ProductResultScreenState extends State<ProductResultScreen> {
  // In a real app, this should come from a Provider/State Management
  final Set<String> _userAllergens = {'Hazelnuts', 'Milk (Dairy)', 'Gluten'}; 

  late Future<Product?> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = ProductService.getProduct(widget.barcode);
    _productFuture.then((product) {
       if (product != null) {
          _saveToHistory(product);
       }
    });
  }

  Future<void> _saveToHistory(Product product) async {
    final detectedAllergens = ProductService.checkAllergens(product, _userAllergens);
    final isSafe = detectedAllergens.isEmpty;
    final name = product.productName ?? product.brands ?? 'Unknown Product';

    final item = ScanItem(
      barcode: widget.barcode,
      productName: name,
      isSafe: isSafe,
      scanDate: DateTime.now(),
    );

    await DatabaseHelper.instance.create(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<Product?>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
             return Center(
               child: Padding(
                 padding: const EdgeInsets.all(24.0),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const Icon(Icons.search_off, size: 80, color: Colors.grey),
                     const SizedBox(height: 24),
                     Text(
                       "Product Not Found",
                       style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                     ),
                     const SizedBox(height: 8),
                     const Text(
                       "We couldn't find this product in our database. You can add it yourself to help others!",
                       textAlign: TextAlign.center,
                       style: TextStyle(color: Colors.grey),
                     ),
                     const SizedBox(height: 16),
                     Text("Barcode: ${widget.barcode}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                     const SizedBox(height: 32),
                     ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to Add Product Screen
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add Product feature coming soon!')));
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Add Product Manually'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          backgroundColor: const Color(0xFF00C9A7),
                          foregroundColor: Colors.white,
                        ),
                     ),
                   ],
                 ),
               ),
             );
          }

          final product = snapshot.data!;
          final detectedAllergens = ProductService.checkAllergens(product, _userAllergens);
          // final detectedAllergens = <String>[];
          final bool containsAllergen = detectedAllergens.isNotEmpty;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product Image/Header
                Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: Stack(
                    children: [
                       if (product.imageFrontUrl != null)
                        Image.network(product.imageFrontUrl!, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                         errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.broken_image, size: 64, color: Colors.grey));
                         },
                        )
                       else
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, size: 80, color: Colors.grey[400]),
                            ],
                          ),
                        ),
                        
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Alert Box
                      if (containsAllergen)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5E5E).withValues(alpha: 0.1),
                            border: Border.all(color: const Color(0xFFFF5E5E)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF5E5E), size: 32),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Not Safe for You',
                                      style: TextStyle(
                                        color: Color(0xFFFF5E5E),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Contains: ${detectedAllergens.join(", ")}',
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().shake(duration: 500.ms)
                      else 
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C9A7).withValues(alpha: 0.1),
                            border: Border.all(color: const Color(0xFF00C9A7)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                               Icon(Icons.check_circle, color: Color(0xFF00C9A7), size: 32),
                               SizedBox(width: 16),
                               Text("Seems Safe", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00C9A7), fontSize: 16)),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),
                      
                      Text(
                        product.productName ?? 'Unknown Product',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                       const SizedBox(height: 8),
                       Text(product.brands ?? '', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                       const SizedBox(height: 16),

                      Row(
                        children: [
                          if (product.allergens?.ids?.isNotEmpty ?? false) ...[
                             _buildBadge(context, '${product.allergens!.ids!.length} Allergens listed', Colors.orange),
                          ]
                        ],
                      ),
                      
                       const SizedBox(height: 24),
                       const Divider(),
                       const SizedBox(height: 16),
                       
                       Text(
                        'Ingredients',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.ingredientsText ?? 'No ingredients listed.',
                        style: const TextStyle(height: 1.5, fontSize: 16, color: Colors.black87),
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
