import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scanme_app/services/database_helper.dart';
import 'package:scanme_app/services/session_manager.dart';

class AllergenSelectionScreen extends StatefulWidget {
  final bool fromSettings;
  const AllergenSelectionScreen({super.key, this.fromSettings = false});

  @override
  State<AllergenSelectionScreen> createState() => _AllergenSelectionScreenState();
}

class _AllergenSelectionScreenState extends State<AllergenSelectionScreen> {
  final List<String> allergens = [
    'Peanuts',
    'Tree Nuts',
    'Milk (Dairy)',
    'Eggs',
    'Soy',
    'Gluten',
    'Fish',
    'Shellfish',
    'Sesame',
    'Mustard',
  ];

  final Set<String> _selectedAllergens = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllergens();
  }

  Future<void> _loadAllergens() async {
    final userId = SessionManager().currentUserId;
    if (userId != null) {
      final savedAllergens = await DatabaseHelper.instance.getUserAllergens(userId);
      setState(() {
        _selectedAllergens.addAll(savedAllergens);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAllergen(String allergen) async {
    final userId = SessionManager().currentUserId;
    if (userId == null) return; // Should navigate to login if null

    setState(() {
      if (_selectedAllergens.contains(allergen)) {
        _selectedAllergens.remove(allergen);
        DatabaseHelper.instance.removeUserAllergen(userId, allergen);
      } else {
        _selectedAllergens.add(allergen);
        DatabaseHelper.instance.addUserAllergen(userId, allergen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Allergens'),
        leading: widget.fromSettings
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/scan'),
              )
            : null,
        actions: [
          if (widget.fromSettings)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: () async {
                await SessionManager().logout();
                if (context.mounted) context.go('/');
              },
            )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What are you avoiding?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select all ingredients that you need to be warned about.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: allergens.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final allergen = allergens[index];
                final isSelected = _selectedAllergens.contains(allergen);
                return InkWell(
                  onTap: () => _toggleAllergen(allergen),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade200,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[100],
                          foregroundColor: isSelected
                              ? Colors.white
                              : Colors.grey[500],
                          child: Icon(getIconForAllergen(allergen), size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            allergen,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey[800],
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          ).animate().scale(),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (50 * index).ms).slideX();
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                context.go('/scan');
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Save & Continue'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData getIconForAllergen(String allergen) {
    if (allergen.contains('Nut')) return Icons.grass;
    if (allergen.contains('Milk')) return Icons.local_drink;
    if (allergen.contains('Fish')) return Icons.set_meal;
    return Icons.no_food;
  }
}
