import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductResultScreen extends StatelessWidget {
  const ProductResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    const bool containsAllergen = true;
    final List<String> detectedAllergens = ['Hazelnuts', 'Milk'];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image/Header
            Container(
              height: 250,
              color: Colors.grey[200],
              child: Stack(
                children: [
                   Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cookie, size: 80, color: Colors.brown[400]),
                        const SizedBox(height: 16),
                        const Text("Mock Hazelnut Spread", style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold)),
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
                    ).animate().shake(duration: 500.ms),

                  const SizedBox(height: 24),
                  
                  Text(
                    'Nutella Hazelnut Spread',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                   const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildBadge(context, 'Vegetarian', Colors.green),
                      const SizedBox(width: 8),
                      _buildBadge(context, 'Gluten Free', Colors.orange), // Example
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
                  const Text(
                    'Sugar, Palm Oil, Hazelnuts (13%), Skimmed Milk Powder (8.7%), Fat-Reduced Cocoa (7.4%), Emulsifier: Lecithins (Soy), Vanillin.',
                    style: TextStyle(height: 1.5, fontSize: 16, color: Colors.black87),
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                   Text(
                    'Nutrition Facts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                   const SizedBox(height: 12),
                  _buildNutrientRow('Calories', '539 kcal'),
                  _buildNutrientRow('Fat', '30.9 g'),
                  _buildNutrientRow('Sugars', '56.3 g'),
                  _buildNutrientRow('Protein', '6.3 g'),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
