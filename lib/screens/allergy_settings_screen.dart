import 'package:flutter/material.dart';

class Allergen {
  final String id;
  final String name;
  final String category;

  const Allergen({
    required this.id,
    required this.name,
    required this.category,
  });
}


const List<Allergen> kAllergenList = [
  Allergen(id: 'gluten', name: 'Gluten', category: 'Gıda'),
  Allergen(id: 'lactose', name: 'Laktoz / Süt Ürünleri', category: 'Gıda'),
  Allergen(id: 'peanut', name: 'Yer Fıstığı', category: 'Kuruyemiş'),
  Allergen(id: 'tree_nut', name: 'Fındık / Ceviz / Badem', category: 'Kuruyemiş'),
  Allergen(id: 'soy', name: 'Soya', category: 'Gıda'),
  Allergen(id: 'egg', name: 'Yumurta', category: 'Gıda'),
  Allergen(id: 'fish', name: 'Balık', category: 'Gıda'),
  Allergen(id: 'shellfish', name: 'Kabuklu Deniz Ürünleri', category: 'Gıda'),
  Allergen(id: 'gluten_free_additive', name: 'Glutamat (MSG vb.)', category: 'Katkı Maddesi'),
  Allergen(id: 'paraben', name: 'Paraben', category: 'Kozmetik'),
  Allergen(id: 'sls', name: 'SLS / SLES', category: 'Kozmetik'),
  Allergen(id: 'fragrance', name: 'Parfüm / Fragrance', category: 'Kozmetik'),
];

class AllergySettingsScreen extends StatefulWidget {
  const AllergySettingsScreen({Key? key}) : super(key: key);

  @override
  State<AllergySettingsScreen> createState() => _AllergySettingsScreenState();
}

class _AllergySettingsScreenState extends State<AllergySettingsScreen> {
  String _searchQuery = '';
  final Set<String> _selectedAllergenIds = {};

  @override
  Widget build(BuildContext context) {
    // Arama filtresi
    final filteredAllergens = kAllergenList.where((allergen) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return allergen.name.toLowerCase().contains(query) ||
          allergen.category.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerji Ayarları'),
      ),
      body: Column(
        children: [
          // Arama kutusu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Maddenin adını ara',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Liste
          Expanded(
            child: ListView.builder(
              itemCount: filteredAllergens.length,
              itemBuilder: (context, index) {
                final allergen = filteredAllergens[index];
                final isSelected = _selectedAllergenIds.contains(allergen.id);

                return CheckboxListTile(
                  title: Text(allergen.name),
                  subtitle: Text(allergen.category),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedAllergenIds.add(allergen.id);
                      } else {
                        _selectedAllergenIds.remove(allergen.id);
                      }
                    });
                  },
                );
              },
            ),
          ),

          // Kaydet butonu
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSavePressed,
                  child: const Text('Kaydet'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSavePressed() {
    
    final selectedNames = kAllergenList
        .where((a) => _selectedAllergenIds.contains(a.id))
        .map((a) => a.name)
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kaydedilen Alerjenler'),
          content: Text(
            selectedNames.isEmpty
                ? 'Herhangi bir alerjen seçilmedi.'
                : selectedNames.join('\n'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );

    // İleride:
    // backendService.updateUserAllergies(_selectedAllergenIds.toList());
  }
}