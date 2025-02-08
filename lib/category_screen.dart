import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tlaxcala_world/feedback/feedback_methods.dart';
import 'package:tlaxcala_world/main.dart';
import 'business_model.dart';
import 'details_screen.dart';
import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

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
  String _sortCriterion = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFilteredBusinesses();
  }

  Future<void> deleteAllHiveBoxes() async {
    await Hive.close();
    await Hive.deleteFromDisk();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MyApp(),
      ),
    );
  }

  Future<void> _loadFilteredBusinesses() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final now = DateTime.now();
      final hiveBoxName =
          'filtered_businesses_${widget.businessType}_${widget.category}';

      if (!await Hive.boxExists(hiveBoxName)) {
        // Fetch from Firebase
        final querySnapshot = await firestore
            .collection('businesses')
            .where('businessType', isEqualTo: widget.businessType)
            .where('category', isEqualTo: widget.category)
            .get();

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
                  business.municipal
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  _searchQuery.isEmpty)
              .toList()
            ..shuffle();
        });
      }
    } catch (e) {
      showSnackbar(context, 'Error loading filtered businesses: $e');
    } finally {}
  }

  Future<void> _applySorting() async {
    setState(() {
      // isLoading = true;
      switch (_sortCriterion) {
        case 'Date':
          _filteredBusinesses
              .sort((a, b) => a.eventDate.compareTo(b.eventDate));
          setState(() {
            isLoading = false;
          });
          break;
        case 'Municipal':
          _filteredBusinesses.sort((a, b) =>
              a.municipal.toLowerCase().compareTo(b.municipal.toLowerCase()));
          setState(() {
            isLoading = false;
          });
          break;
        case 'Alphabetical':
          _filteredBusinesses.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          setState(() {
            isLoading = false;
          });
          break;
        case 'Schedule':
          _filteredBusinesses
              .sort((a, b) => a.openingHours.compareTo(b.openingHours));
          setState(() {
            isLoading = false;
          });
          break;
        case 'Location':
          _sortByProximity();

          break;
      }
    });
  }

  Future<void> _sortByProximity() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar(context
              .tr('Location permission is required to sort by proximity'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(context.tr(
            'Location permissions are permanently denied. Please enable them in settings.'));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double userLat = position.latitude;
      double userLng = position.longitude;

      print('User location: Lat=$userLat, Lng=$userLng');
      print(
          'Businesses before sort: ${_filteredBusinesses.map((e) => e.locationLink).toList()}');

      // Sort businesses by proximity
      _filteredBusinesses.sort((a, b) {
        double distanceA =
            _calculateDistanceFromLink(a.locationLink, userLat, userLng);
        double distanceB =
            _calculateDistanceFromLink(b.locationLink, userLat, userLng);
        print(
            'Comparing: ${a.locationLink} (Dist: $distanceA) vs ${b.locationLink} (Dist: $distanceB)');
        return distanceA.compareTo(distanceB);
      });

      print(
          'Businesses after sort: ${_filteredBusinesses.map((e) => e.locationLink).toList()}');

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error getting location: $e');
      _showSnackBar('Failed to get location: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  double _calculateDistanceFromLink(
      String link, double userLat, double userLng) {
    try {
      final regex = RegExp(r'@([-.\d]+),([-.\d]+)');
      final match = regex.firstMatch(link);
      if (match != null) {
        double lat = double.parse(match.group(1)!);
        double lng = double.parse(match.group(2)!);
        return _haversineDistance(userLat, userLng, lat, lng);
      } else {
        print('Invalid link format: $link');
        return double.infinity;
      }
    } catch (e) {
      print('Error parsing link: $e');
      return double.infinity;
    }
  }

  double _haversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth's radius in km
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in km
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
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
      body: SafeArea(
        // Ensures content doesn't overlap system UI
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: context.tr('Search'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
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
                  const SizedBox(width: 2),
                  IconButton(
                    icon: const Icon(Icons.sort, color: Color(0xFF270949)),
                    onPressed: () => _showSortDialog(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredBusinesses.isEmpty
                      ? const Center(child: Text("No businesses found."))
                      : ListView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(), // Forces scrolling even if content is less
                          itemCount: _filteredBusinesses.length,
                          itemBuilder: (context, index) {
                            final business = _filteredBusinesses[index];
                            var imagePathh = "";
                            for (String imagePath
                                in business.imagePaths.take(1)) {
                              if (imagePath.isNotEmpty) {
                                imagePathh = imagePath;
                              }
                            }

                            return GestureDetector(
                              onTap: () => _navigateToDetailsScreen(business),
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Image Section
                                        SizedBox(
                                          width: 150,
                                          height: 175,
                                          child: Image.network(
                                            imagePathh,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child: Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.grey),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        // Details Section
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Business Name (Always shown)
                                                Text(
                                                  business.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        fontSize: 20,
                                                        color: const Color(
                                                            0xFF270949),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),

                                                // Municipal Row (Only if non-empty)
                                                if (business.municipal
                                                    .trim()
                                                    .isNotEmpty) ...[
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.location_on,
                                                          size: 16,
                                                          color: Colors.black),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          business.municipal,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.copyWith(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],

                                                // Event Date Row (Only if non-empty)
                                                if (business.eventDate
                                                    .trim()
                                                    .isNotEmpty) ...[
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.event,
                                                          size: 16,
                                                          color: Colors.black),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          business.eventDate,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.copyWith(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],

                                                // Schedule Row (Only if openingHours is non-empty)
                                                if (business.openingHours
                                                    .trim()
                                                    .isNotEmpty) ...[
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.access_time,
                                                          size: 16,
                                                          color: Colors.black),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${context.tr('Schedule')}: ${business.openingHours}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(thickness: 0.1),
                                ],
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
              RadioListTile(
                title: Text(context.tr('Close to you')),
                value: 'Location',
                groupValue: _sortCriterion,
                onChanged: (value) {
                  setState(() {
                    _sortCriterion = "Location";
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
