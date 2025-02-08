import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tlaxcala_world/all_methods.dart';
import 'package:tlaxcala_world/data_manager.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    logAppVisit();
    _loadBusinessTypes();
  }

  Future<void> launchPhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Icon getLeadingIcon(String businessType) {
    if (businessType == "Hotels") {
      return const Icon(Icons.hotel, color: Color(0xFF270949));
    }
    if (businessType == "Cinema") {
      return const Icon(Icons.tv, color: Color(0xFF270949));
    }
    if (businessType == "Restaurants") {
      return const Icon(Icons.restaurant, color: Color(0xFF270949));
    }
    if (businessType == "Clubs and Bars") {
      return const Icon(Icons.liquor, color: Color(0xFF270949));
    }
    if (businessType == "Art and Culture") {
      return const Icon(Icons.palette, color: Color(0xFF270949));
    }
    if (businessType == "Conferences and Exhibitions") {
      return const Icon(Icons.museum, color: Color(0xFF270949));
    }
    if (businessType == "Schools") {
      return const Icon(Icons.school, color: Color(0xFF270949));
    }
    if (businessType == "Gyms") {
      return const Icon(Icons.sports_gymnastics, color: Color(0xFF270949));
    }
    if (businessType == "Parties") {
      return const Icon(Icons.party_mode, color: Color(0xFF270949));
    }
    if (businessType == "Theater") {
      return const Icon(Icons.live_tv, color: Color(0xFF270949));
    }
    if (businessType == "Events") {
      return const Icon(Icons.event, color: Color(0xFF270949));
    }
    if (businessType == "Dances and Concerts") {
      return const Icon(Icons.nightlife, color: Color(0xFF270949));
    }
    if (businessType == "Doctors and Hospitals") {
      return const Icon(Icons.medication, color: Color(0xFF270949));
    }
    if (businessType == "Consultancies") {
      return const Icon(Icons.person, color: Color(0xFF270949));
    }
    if (businessType == "Beauty") {
      return const Icon(Icons.face, color: Color(0xFF270949));
    }
    if (businessType == "Service") {
      return const Icon(Icons.support_agent, color: Color(0xFF270949));
    }
    if (businessType == "Newspapers") {
      return const Icon(Icons.newspaper, color: Color(0xFF270949));
    }

    return const Icon(Icons.business, color: Color(0xFF270949));
  }

  Future<void> _loadBusinessTypes() async {
    final businessDataManager = BusinessDataManager();

    // Load data from Hive
    final data = await businessDataManager.loadBusinessDataFromHive();
    final businessTypes = data['businessTypes'] as List<String>;
    final categoriesByType =
        data['categoriesByType'] as Map<String, List<String>>;

    // Update UI
    setState(() {
      _businessTypes = businessTypes;
      _categoriesByType = categoriesByType;
    });
  }

  void _navigateToCategoryScreen(String type, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CategoryScreen(businessType: type, category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBusinessTypes = _businessTypes.where((type) {
      return context
              .tr(type)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (_categoriesByType[type]?.any((category) => context
                  .tr(category)
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase())) ??
              false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          context.tr('Select Your Service'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16).copyWith(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: context.tr('Search services...'),
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: Color(0xFF6A11CB)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),

          if (filteredBusinessTypes.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      context.tr("No services found"),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (filteredBusinessTypes.isNotEmpty)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filteredBusinessTypes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final businessType = filteredBusinessTypes[index];
                  final categories = _categoriesByType[businessType] ?? [];

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      key: PageStorageKey(businessType),
                      title: Text(
                        context.tr(businessType),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                          fontSize: 16,
                        ),
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A11CB).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: getLeadingIcon(businessType),
                      ),
                      trailing: Icon(
                        _expandedBusinessType == businessType
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: const Color(0xFF6A11CB),
                      ),
                      initiallyExpanded: _expandedBusinessType == businessType,
                      onExpansionChanged: (expanded) => setState(() {
                        _expandedBusinessType = expanded ? businessType : null;
                      }),
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          child: Column(
                            children: categories
                                .map((category) => ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(horizontal: 16),
                                      leading: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF6A11CB),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      title: Text(
                                        context.tr(category),
                                        style: const TextStyle(
                                          color: Color(0xFF4A4A4A),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: Color(0xFF6A11CB),
                                      ),
                                      onTap: () => _navigateToCategoryScreen(
                                          businessType, category),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Contact Section
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => launchPhoneCall('2463608618'),
                child: Padding(
                  padding: const EdgeInsets.only(left:0,right:0,top:5,bottom:5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone_rounded, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        context.tr("Hire our service: 2463608618"),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
