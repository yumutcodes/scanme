import 'package:openfoodfacts/openfoodfacts.dart';

class ProductService {
  // Mock Database for fallback
  static final Map<String, Product> _mockDb = {
    '111111': Product(
      barcode: '111111',
      productName: 'Mock Apple',
      brands: 'Nature',
      ingredientsText: 'Just delicious apple.',
      imageFrontUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      allergens: Allergens([], []),
    ),
    '222222': Product(
      barcode: '222222',
      productName: 'Mock Peanut Butter',
      brands: 'Nutty',
      ingredientsText: 'Roasted Peanuts, Salt, Sugar.',
      imageFrontUrl: 'https://images.unsplash.com/photo-1526435939226-b040e0be22cb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      allergens: Allergens([], ['en:peanuts']),
    ),
    '333333': Product(
      barcode: '333333',
      productName: 'Mock Soy Milk',
      brands: 'VeganLife',
      ingredientsText: 'Water, Soybeans, Calcium.',
      imageFrontUrl: 'https://images.unsplash.com/photo-1628045620922-a988d2347b5b?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      allergens: Allergens([], ['en:soybeans']),
    ),
    // Nutella (Global)
    '3017620422003': Product(
      barcode: '3017620422003',
      productName: 'Nutella Hazelnut Spread',
      brands: 'Ferrero',
      ingredientsText: 'Sugar, Palm Oil, Hazelnuts (13%), Skimmed Milk Powder (8.7%), Fat-Reduced Cocoa (7.4%), Emulsifier: Lecithin (Soy), Vanillin',
      imageFrontUrl: 'https://images.openfoodfacts.org/images/products/301/762/042/2003/front_en.594.400.jpg',
      allergens: Allergens([], ['en:hazelnuts', 'en:milk', 'en:soybeans']),
    ),
    // Turkey Products
    '8690504020509': Product(
       barcode: '8690504020509',
       productName: 'Ülker Çikolatalı Gofret',
       brands: 'Ülker',
       ingredientsText: 'Şeker, Buğday Unu, Bitkisel Yağlar, Fındık (%6), Süt Tozu, Kakao Tozu, Peynir Altı Suyu Tozu, Emülgatör (Soya Lesitini), Tuz, Kabartıcılar, Aroma Vericiler.',
       imageFrontUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR616GfwGgVqC85W3iC3wHj6WqG2k0R9n8LzA&s', // Placeholder URL
       allergens: Allergens([], ['en:hazelnuts', 'en:milk', 'en:gluten', 'en:soybeans']),
    ),
    '8690624103128': Product(
       barcode: '8690624103128',
       productName: 'Eti Negro',
       brands: 'Eti',
       ingredientsText: 'Buğday Unu (Gluten), Şeker, Bitkisel Yağ, Kakao (%8), Süt Tozu, Kabartıcılar, Tuz, Aroma Vericiler.',
       imageFrontUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTGqj021q6s2k0R9n8LzA&s', // Placeholder URL
       allergens: Allergens([], ['en:gluten', 'en:milk']),
    ),
  };

  static Future<Product?> getProduct(String barcode) async {
    // 1. Try Mock DB first (for testing stability/demo) or Validation fallback
    // In a real scenario, this would be try API -> catch -> return Mock
    // For this demo, let's try API first, then Mock.
    
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
      if (result.status == ProductResultV3.statusSuccess && result.product != null) {
        return result.product;
      } else {
        // API returned no product, try Mock
        return _mockDb[barcode];
      }
    } catch (e) {
      // Network/API error, try Mock
      // debugPrint('API Error: $e');
      return _mockDb[barcode];
    }
  }

  // Basic matching logic
  static List<String> checkAllergens(Product product, Set<String> userAllergens) {
    final List<String> detected = [];
    final ingredients = product.ingredientsText?.toString().toLowerCase() ?? '';
    // Use tags/ids for better matching from API
    final allergens = product.allergens?.ids ?? []; 

    // Helper map to match user selections to potential ingredient keywords and tags
    final Map<String, List<String>> lexicon = {
      'Peanuts': ['peanut', 'arachis', 'en:peanuts'],
      'Tree Nuts': ['nut', 'almond', 'cashew', 'walnut', 'hazelnut', 'pecan', 'en:nuts', 'en:hazelnuts'],
      'Milk (Dairy)': ['milk', 'lactose', 'cheese', 'cream', 'whey', 'butter', 'yogurt', 'en:milk'],
      'Eggs': ['egg', 'albumin', 'en:eggs'],
      'Soy': ['soy', 'soya', 'tofu', 'lecithin', 'en:soybeans'],
      'Gluten': ['gluten', 'wheat', 'barley', 'rye', 'malt', 'en:gluten'],
      'Fish': ['fish', 'tuna', 'salmon', 'cod','anchovy', 'en:fish'],
      'Shellfish': ['shellfish', 'shrimp', 'crab', 'lobster', 'prawn', 'en:crustaceans', 'en:molluscs'],
      'Sesame': ['sesame', 'en:sesame-seeds'],
      'Mustard': ['mustard', 'en:mustard'],
    };

    for (final allergen in userAllergens) {
      final keywords = lexicon[allergen] ?? [allergen.toLowerCase()];
      
      // Check ingredients text
      bool foundInText = keywords.any((keyword) => ingredients.contains(keyword.toLowerCase()));
      
      // Check explicit allergen tags from API
      bool foundInTags = allergens.any((tag) => keywords.any((keyword) => tag.toLowerCase().contains(keyword.toLowerCase())));

      if (foundInText || foundInTags) {
        detected.add(allergen);
      }
    }
    return detected;
  }
}
