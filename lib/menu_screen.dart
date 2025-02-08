import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tlaxcala_world/all_methods.dart';
import 'package:tlaxcala_world/data_manager.dart';
import 'category_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<String> _businessTypes = [];
  Map<String, List<String>> _categoriesByType = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    logAppVisit();
    _loadBusinessTypes();
  }

  Future<void> _loadBusinessTypes() async {
    final businessDataManager = BusinessDataManager();
    final data = await businessDataManager.loadBusinessDataFromHive();
    setState(() {
      _businessTypes = data['businessTypes'] as List<String>;
      _categoriesByType = data['categoriesByType'] as Map<String, List<String>>;
    });
  }

  void _navigateToCategoryScreen(String type, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryScreen(businessType: type, category: category),
      ),
    );
  }

  Icon getLeadingIcon(String businessType) {
    final iconMap = {
      "Hotels": Icons.hotel,
      "Cinema": Icons.tv,
      "Restaurants": Icons.restaurant,
      "Clubs and Bars": Icons.liquor,
      "Art and Culture": Icons.palette,
      "Conferences and Exhibitions": Icons.museum,
      "Schools": Icons.school,
      "Gyms": Icons.sports_gymnastics,
      "Parties": Icons.party_mode,
      "Theater": Icons.live_tv,
      "Events": Icons.event,
      "Dances and Concerts": Icons.nightlife,
      "Doctors and Hospitals": Icons.medication,
      "Consultancies": Icons.person,
      "Beauty": Icons.face,
      "Service": Icons.support_agent,
      "Newspapers": Icons.newspaper,
    };
    return Icon(iconMap[businessType] ?? Icons.business, color: Colors.white,size: 35,);
  }

  void _showCategoryDialog(String businessType) {
    final categories = _categoriesByType[businessType] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr(businessType),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF270949)),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToCategoryScreen(businessType, category);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:Color(0xFFF95B3D),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                context.tr(category),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.8), size: 18),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBusinessTypes = _businessTypes.where((type) {
      return context.tr(type).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (_categoriesByType[type]?.any((category) =>
              context.tr(category).toLowerCase().contains(_searchQuery.toLowerCase())) ??
              false);
    }).toList();

    return Scaffold(
      backgroundColor:Colors.white,
      // appBar: AppBar(
      //   foregroundColor: Colors.white,
      //   title: Text(context.tr('Select Your Service')),
      //   centerTitle: true,
      //   backgroundColor: const Color(0xFFF95B3D),
      //   elevation: 4,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.tr('Search services...'),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF270949)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.8,
                ),
                itemCount: filteredBusinessTypes.length,
                itemBuilder: (context, index) {
                  final businessType = filteredBusinessTypes[index];
                  return GestureDetector(
                    onTap: () => _showCategoryDialog(businessType),
                    child: Container(
                      decoration: BoxDecoration(
                        color:Color(0xFFF95B3D),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              context.tr(businessType),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: getLeadingIcon(businessType),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
