import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'database_helper.dart';
import 'category_screen.dart'; // Import your CategoryScreen

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<String> _businessTypes = [];
  final Map<String, List<String>> _categoriesByType = {};
  String? _expandedBusinessType;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    final filteredBusinessTypes = _businessTypes.where((type) {
      return type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (_categoriesByType[type]?.any((category) => 
              category.toLowerCase().contains(_searchQuery.toLowerCase())) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Business Menu')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: context.tr('Search'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredBusinessTypes.length,
              itemBuilder: (context, index) {
                final businessType = filteredBusinessTypes[index];
                final categories = _categoriesByType[businessType] ?? [];

                return Padding(
                  padding: const EdgeInsets.only(left:16.0,right:16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ExpansionTile(
                      key: PageStorageKey(businessType),
                      title: Text(
                        context.tr(businessType),
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      initiallyExpanded: _expandedBusinessType == businessType,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _expandedBusinessType = expanded ? businessType : null;
                        });
                      },
                      children: categories
                          .where((category) => category.toLowerCase().contains(_searchQuery.toLowerCase()))
                          .map((category) {
                        return ListTile(
                          title: Text(context.tr(category)),
                          onTap: () => _navigateToCategoryScreen(businessType, category),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
