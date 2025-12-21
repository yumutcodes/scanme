import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  final Set<String> _userAllergens = {'Hazelnuts', 'Milk (Dairy)', 'Gluten'}; // Mock user state

  late Future<Product?> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = ProductService.getProduct(widget.barcode);
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
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.search_off, size: 64, color: Colors.grey),
                   const SizedBox(height: 16),
                   const Text("Product not found"),
                   const SizedBox(height: 8),
                   Text("Barcode: ${widget.barcode}", style: const TextStyle(color: Colors.grey)),
                 ],
               ),
             );
          }

          final product = snapshot.data!;
          final detectedAllergens = ProductService.checkAllergens(product, _userAllergens);
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
                        Image.network(product.imageFrontUrl!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
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
                          if (product.allergens?.names != null) ...[
                             // Just showing a count or generic badge for simplicity
                             _buildBadge(context, '${product.allergens!.names.length} Allergens listed', Colors.orange),
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
