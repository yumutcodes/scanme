import 'package:openfoodfacts/openfoodfacts.dart';

class ProductService {
  static Future<Product?> getProduct(String barcode) async {
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      language: OpenFoodFactsLanguage.ENGLISH,
      fields: [
        ProductField.NAME,
        ProductField.BRANDS,
        ProductField.INGREDIENTS_TEXT,
        ProductField.ALLERGENS,
        ProductField.NUTRIMENTS,
        ProductField.IMAGE_FRONT_URL,
      ],
      version: ProductQueryVersion.v3,
    );

    try {
      final ProductResultV3 result = await OpenFoodAPIClient.getProductV3(configuration);
      if (result.status == ProductResultV3.statusSuccess) {
        return result.product;
      } else {
        return null;
      }
    } catch (e) {
      // debugPrint('Error fetching product: $e');
      return null;
    }
  }

  // Basic matching logic
  static List<String> checkAllergens(Product product, Set<String> userAllergens) {
    final List<String> detected = [];
    final ingredients = product.ingredientsText?.toLowerCase() ?? '';
    final allergens = product.allergens?.names ?? []; 

    // Helper map to match user selections to potential ingredient keywords
    final Map<String, List<String>> lexicon = {
      'Peanuts': ['peanut', 'arachis'],
      'Tree Nuts': ['nut', 'almond', 'cashew', 'walnut', 'hazelnut', 'pecan'],
      'Milk (Dairy)': ['milk', 'lactose', 'cheese', 'cream', 'whey', 'butter', 'yogurt'],
      'Eggs': ['egg', 'albumin'],
      'Soy': ['soy', 'soya', 'tofu', 'lecithin'],
      'Gluten': ['gluten', 'wheat', 'barley', 'rye', 'malt'],
      'Fish': ['fish', 'tuna', 'salmon', 'cod','anchovy'],
      'Shellfish': ['shellfish', 'shrimp', 'crab', 'lobster', 'prawn'],
      'Sesame': ['sesame'],
      'Mustard': ['mustard'],
    };

    for (final allergen in userAllergens) {
      final keywords = lexicon[allergen] ?? [allergen.toLowerCase()];
      
      // Check ingredients text
      bool foundInText = keywords.any((keyword) => ingredients.contains(keyword));
      
      // Check explicit allergen tags from API
      // API often returns strings like "en:peanuts"
      bool foundInTags = allergens.any((tag) => keywords.any((keyword) => tag.toLowerCase().contains(keyword)));

      if (foundInText || foundInTags) {
        detected.add(allergen);
      }
    }
    return detected;
  }
}
