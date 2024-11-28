import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'database_helper.dart';
import 'business_model.dart';
import 'category_screen.dart'; // Import your CategoryScreen

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<String> _businessTypes = [];
  Map<String, List<String>> _categoriesByType = {};
  String? _expandedBusinessType;

  @override
  void initState() {
    super.initState();
    _loadBusinessTypes();
  }

  Future<void> _loadBusinessTypes() async {
    final businessTypes = await DatabaseHelper().getUniqueBusinessTypes();
    setState(() {
      _businessTypes = businessTypes;
    });

    // Load categories for each business type
    for (String type in businessTypes) {
      final categories = await DatabaseHelper().getCategoriesForType(type);
      setState(() {
        _categoriesByType[type] = categories;
      });
    }
  }

  void _navigateToCategoryScreen(String type, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryScreen(businessType: type, category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Business Menu')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _businessTypes.length,
          itemBuilder: (context, index) {
            final businessType = _businessTypes[index];
            final categories = _categoriesByType[businessType] ?? [];

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ExpansionTile(
                key: PageStorageKey(businessType),
                title: Text(
                  businessType,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: _expandedBusinessType == businessType,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _expandedBusinessType = expanded ? businessType : null;
                  });
                },
                children: categories.map((category) {
                  return ListTile(
                    title: Text(category),
                    onTap: () => _navigateToCategoryScreen(businessType, category),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
