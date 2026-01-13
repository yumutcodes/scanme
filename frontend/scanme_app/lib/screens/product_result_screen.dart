import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scanme_app/services/database_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:scanme_app/services/product_service.dart';
import 'package:scanme_app/services/session_manager.dart';
import 'package:scanme_app/services/api_service.dart';
import 'package:logger/logger.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scanme_app/widgets/shimmer_loading.dart';

class ProductResultScreen extends StatefulWidget {
  final String barcode;

  const ProductResultScreen({super.key, required this.barcode});

  @override
  State<ProductResultScreen> createState() => _ProductResultScreenState();
}

class _ProductResultScreenState extends State<ProductResultScreen> {
  final Set<String> _userAllergens = {};
  final Logger _logger = Logger();

  ProductResult? _productResult;
  bool _isLoading = true;
  bool _hasSavedToHistory = false;

  @override
  void initState() {
    super.initState();
    _loadUserAllergens();
    _fetchProduct();
  }

  Future<void> _loadUserAllergens() async {
    final userId = SessionManager().currentUserId;
    if (userId != null) {
      try {
        final loaded = await DatabaseHelper.instance.getUserAllergens(userId);
        setState(() {
          _userAllergens.addAll(loaded);
        });
      } catch (e) {
        _logger.e('Failed to load user allergens', error: e);
      }
    }
  }

  Future<void> _fetchProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ProductService.getProductWithResult(widget.barcode);

      if (mounted) {
        setState(() {
          _productResult = result;
          _isLoading = false;
        });

        // Save to history only once on successful fetch
        if (result.isSuccess && result.product != null && !_hasSavedToHistory) {
          await _saveToHistory(result.product!);
          _hasSavedToHistory = true;
        }
      }
    } catch (e) {
      _logger.e('Failed to fetch product', error: e);
      if (mounted) {
        setState(() {
          _productResult = ProductResult(
            errorMessage: 'An unexpected error occurred. Please try again.',
          );
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveToHistory(Product product) async {
    try {
      final detectedAllergens = ProductService.checkAllergens(
        product,
        _userAllergens,
      );
      final isSafe = detectedAllergens.isEmpty;
      final name = product.productName ?? product.brands ?? 'Unknown Product';

      final item = ScanItem(
        barcode: widget.barcode,
        productName: name,
        isSafe: isSafe,
        scanDate: DateTime.now(),
      );

      // If logged in to backend, save to backend first and get the backend ID
      int? backendId;
      if (SessionManager().hasBackendToken) {
        backendId = await ApiService.saveHistory(item);
      }

      // Save to local SQLite with backend ID (if available)
      final userId = SessionManager().currentUserId;
      if (userId != null) {
        final itemWithBackendId = item.copyWith(backendId: backendId);
        await DatabaseHelper.instance.create(itemWithBackendId, userId);
      }
      
      _logger.i('Saved scan to history: $name${backendId != null ? ' (backendId: $backendId)' : ''}');
    } catch (e) {
      _logger.e('Failed to save to history', error: e);
    }
  }

  void _retry() {
    _fetchProduct();
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const ProductShimmerLoading();
    }

    if (_productResult == null || _productResult!.isError) {
      if (_productResult?.errorMessage == 'Product not found') {
        return _buildNotFoundState();
      }
      return _buildErrorState();
    }

    if (_productResult!.product == null) {
      return _buildNotFoundState();
    }

    return _buildProductDetails(_productResult!.product!);
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: Colors.orange.shade400,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              'Connection Error',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              _productResult?.errorMessage ?? 'Unable to fetch product data',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 8),
            Text(
              'Barcode: ${widget.barcode}',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                backgroundColor: const Color(0xFF00C9A7),
                foregroundColor: Colors.white,
              ),
            ).animate().fadeIn(delay: 500.ms).scale(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 40,
                color: Colors.amber.shade600,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              'Product Not Found',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              "We couldn't find this product in our database.\nYou can add it yourself to help others!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 8),
            Text(
              'Barcode: ${widget.barcode}',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Add Product feature coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Product'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    backgroundColor: const Color(0xFF00C9A7),
                    foregroundColor: Colors.white,
                  ),
                ).animate().fadeIn(delay: 600.ms).scale(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetails(Product product) {
    final detectedAllergens = ProductService.checkAllergens(
      product,
      _userAllergens,
    );
    final bool containsAllergen = detectedAllergens.isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Data source indicator
          if (_productResult?.isFromMock == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.amber.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.amber.shade800,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Using cached data (offline mode)',
                    style: TextStyle(
                      color: Colors.amber.shade800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Product Image/Header
          Container(
            height: 250,
            color: Colors.grey[200],
            child: Stack(
              children: [
                if (product.imageFrontUrl != null)
                  CachedNetworkImage(
                    imageUrl: product.imageFrontUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: ShimmerContainer(
                          height: 250,
                          width: double.infinity,
                          borderRadius: 0,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image unavailable',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey[400],
                        ),
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
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
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
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFFF5E5E),
                          size: 32,
                        ),
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
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF00C9A7),
                          size: 32,
                        ),
                        SizedBox(width: 16),
                        Text(
                          "Seems Safe",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00C9A7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().scale(duration: 400.ms),

                const SizedBox(height: 24),

                Text(
                  product.productName ?? 'Unknown Product',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.brands ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    if (product.allergens?.ids.isNotEmpty ?? false) ...[
                      _buildBadge(
                        context,
                        '${product.allergens!.ids.length} Allergens listed',
                        Colors.orange,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                Text(
                  'Ingredients',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  product.ingredientsText ?? 'No ingredients listed.',
                  style: const TextStyle(
                    height: 1.5,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
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
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
