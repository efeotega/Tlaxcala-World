import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'business_model.dart';
import 'details_screen.dart';
import 'package:hive/hive.dart';

class CategoryScreen extends StatefulWidget {
  final String businessType;
  final String category;

  const CategoryScreen(
      {super.key, required this.businessType, required this.category});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Business> _filteredBusinesses = [];
  String _searchQuery = '';
  String _sortCriterion = 'Alphabetical';

  @override
  void initState() {
    super.initState();
    _loadFilteredBusinesses();
  }
Future<void> _loadFilteredBusinesses() async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final now = DateTime.now();
  final hiveBoxName = 'filtered_businesses_${widget.businessType}_${widget.category}';

  try {
    // Determine the data source
    if (now.weekday == DateTime.friday || !(await Hive.boxExists(hiveBoxName))) {
      // Fetch from Firebase
      final querySnapshot = await _firestore
          .collection('businesses')
          .where('businessType', isEqualTo: widget.businessType)
          .where('category', isEqualTo: widget.category)
          .get();

      // Map Firestore documents to Business objects
      final businesses = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Business(
          id: data['id'],
          name: data['name'] ?? '',
          businessType: data['businessType'] ?? '',
          facebookPage: data['facebookPage'] ?? '',
          website: data['website'] ?? '',
          category: data['category'] ?? '',
          review: data['review'] ?? '',
          phone: data['phone'] ?? '',
          municipal: data['municipal'] ?? '',
          address: data['address'] ?? '',
          services: data['services'] ?? '',
          addedValue: data['addedValue'] ?? '',
          opinions: data['opinions'] ?? '',
          whatsapp: data['whatsapp'] ?? '',
          promotions: data['promotions'] ?? '',
          locationLink: data['locationLink'] ?? '',
          eventDate: data['eventDate'] ?? '',
          openingHours: data['openingHours'] ?? '',
          closingHours: data['closingHours'] ?? '',
          prices: data['prices'] ?? '',
          imagePaths: data['imagePaths'],
        );
      }).toList();

      // Save to Hive
      final box = await Hive.openBox(hiveBoxName);
      await box.put('businesses', businesses.map((b) => b.toJson()).toList());
      await box.put('lastSynced', now.toIso8601String());

      // Update UI
      setState(() {
        _filteredBusinesses = businesses
            .where((business) =>
                business.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                _searchQuery.isEmpty)
            .toList()
          ..shuffle();
      });
    } else {
      // Fetch from Hive
      final box = await Hive.openBox(hiveBoxName);
      final savedBusinesses = box.get('businesses', defaultValue: []);
      final businesses = (savedBusinesses as List<dynamic>)
          .map((json) =>
              Business.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();

      // Update UI
      setState(() {
        _filteredBusinesses = businesses
            .where((business) =>
                business.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                _searchQuery.isEmpty)
            .toList()
          ..shuffle();
      });
    }
  } catch (e) {
    print('Error loading filtered businesses: $e');
  }
}

  void _applySorting() {
    setState(() {
      switch (_sortCriterion) {
        case 'Date':
          _filteredBusinesses
              .sort((a, b) => a.eventDate.compareTo(b.eventDate));
          break;
        case 'Municipal':
          _filteredBusinesses
              .sort((a, b) => a.municipal.compareTo(b.municipal));
          break;
        case 'Alphabetical':
          _filteredBusinesses.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Schedule':
          _filteredBusinesses
              .sort((a, b) => a.openingHours.compareTo(b.openingHours));
          break;
      }
    });
  }

  void _navigateToDetailsScreen(Business business) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(business: business),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(widget.category)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: context.tr('Search'),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _loadFilteredBusinesses();
              },
            ),
          ),
          Column(
            children: [
              if (_filteredBusinesses.isEmpty)
                Center(
                  child: CircularProgressIndicator()
                ),
            ],
          ),
          Column(
            children: [
              if (_filteredBusinesses.isNotEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height - 150,
                  child: ListView.builder(
                    itemCount: _filteredBusinesses.length,
                    itemBuilder: (context, index) {
                      final business = _filteredBusinesses[index];
                      return Card(
                        color: const Color(0xFFF95B3D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: GestureDetector(
                          onTap: () => _navigateToDetailsScreen(business),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (String imagePath
                                      in business.imagePaths.take(1))
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Image.network(
                                        imagePath,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            title: Text(
                              business.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '${context.tr('Municipal')}: ${business.municipal}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith( color: Colors.white,),
                                  
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  business.eventDate,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${context.tr('Schedule')}: ${business.openingHours}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith( color: Colors.white,),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr('Sort Businesses')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: Text(context.tr('Alphabetical')),
                value: 'Alphabetical',
                groupValue: _sortCriterion,
                onChanged: (value) {
                  setState(() {
                    _sortCriterion = "Alphabetical";
                  });
                  Navigator.pop(context);
                  _applySorting();
                },
              ),
              RadioListTile(
                title: Text(context.tr('Date')),
                value: 'Date',
                groupValue: _sortCriterion,
                onChanged: (value) {
                  setState(() {
                    _sortCriterion = "Date";
                  });
                  Navigator.pop(context);
                  _applySorting();
                },
              ),
              RadioListTile(
                title: Text(context.tr('Municipal')),
                value: 'Municipal',
                groupValue: _sortCriterion,
                onChanged: (value) {
                  setState(() {
                    _sortCriterion = "Municipal";
                  });
                  Navigator.pop(context);
                  _applySorting();
                },
              ),
              RadioListTile(
                title: Text(context.tr('Schedule')),
                value: 'Schedule',
                groupValue: _sortCriterion,
                onChanged: (value) {
                  setState(() {
                    _sortCriterion = "Schedule";
                  });
                  Navigator.pop(context);
                  _applySorting();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
