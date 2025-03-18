import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tlaxcala_world/feedback/feedback_methods.dart';
import 'package:tlaxcala_world/main.dart';
import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:shimmer/shimmer.dart';

import 'business_model.dart';
import 'details_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String businessType;
  final String category;

  const CategoryScreen({
    super.key,
    required this.businessType,
    required this.category,
  });

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
      final hiveBoxName = 'filtered_businesses_${widget.businessType}_${widget.category}';

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
            imagePaths: (data['mediaItems'] as List<dynamic>?)
                ?.map((item) => Map<String, dynamic>.from(item as Map))
                .toList() ?? [],
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
                  business.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  business.municipal.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  _searchQuery.isEmpty)
              .toList()
            ..shuffle();
        });
      } else {
        // Fetch from Hive
        final box = await Hive.openBox(hiveBoxName);
        final savedBusinesses = box.get('businesses', defaultValue: []);
        final businesses = (savedBusinesses as List<dynamic>)
            .map((json) => Business.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();

        // Update UI
        setState(() {
          _filteredBusinesses = businesses
              .where((business) =>
                  business.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  business.municipal.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  _searchQuery.isEmpty)
              .toList()
            ..shuffle();
        });
      }
    } catch (e) {
      showSnackbar(context, 'Error loading filtered businesses: $e');
    }
  }

  // Helper method to build the media widget


Widget _buildMediaWidget(String url) {
  // Define common file extensions for images and videos
  final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
  final videoExtensions = ['mp4', 'mov', 'avi', 'mkv'];

  // Step 1: Parse the URL and extract the path
  Uri uri = Uri.parse(url);
  String path = uri.path; // e.g., "/o/business_images%2F1739942473443.jpg"

  // Step 2: Decode the path to handle URL-encoded characters (e.g., %2F -> /)
  String decodedPath = Uri.decodeComponent(path); // e.g., "o/business_images/1739942473443.jpg"

  // Step 3: Extract the file name from the decoded path
  String fileName = decodedPath.split('/').last; // e.g., "1739942473443.jpg"

  // Step 4: Extract the file extension from the file name
  String extension = fileName.split('.').last.toLowerCase(); // e.g., "jpg"

  // Step 5: Determine the media type and return the appropriate widget
  if (imageExtensions.contains(extension)) {
    // Display the image with a shimmer effect while loading
    return Stack(
      fit: StackFit.expand,
      children: [
        // Shimmer effect as a placeholder
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            color: Colors.grey[300],
          ),
        ),
        // Image widget
        Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              // Image is fully loaded, show the image
              return child;
            } else {
              // While loading, the shimmer effect is visible in the background
              return const SizedBox.shrink(); // Empty widget, shimmer shows through
            }
          },
          errorBuilder: (context, error, stackTrace) {
            // Fallback if the image fails to load
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            );
          },
        ),
      ],
    );
  } else if (videoExtensions.contains(extension)) {
    // Display a placeholder for videos (since no thumbnail is provided)
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.video_library, color: Colors.grey),
      ),
    );
  } else {
    // Fallback for unrecognized file types
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }
}
  Future<void> _applySorting() async {
    setState(() {
      switch (_sortCriterion) {
        case 'Date':
          _filteredBusinesses.sort((a, b) => a.eventDate.compareTo(b.eventDate));
          break;
        case 'Municipal':
          _filteredBusinesses.sort((a, b) => a.municipal.toLowerCase().compareTo(b.municipal.toLowerCase()));
          break;
        case 'Alphabetical':
          _filteredBusinesses.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          break;
        case 'Schedule':
          _filteredBusinesses.sort((a, b) => a.openingHours.compareTo(b.openingHours));
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
          _showSnackBar(context.tr('Location permission is required to sort by proximity'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(context.tr('Location permissions are permanently denied. Please enable them in settings.'));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double userLat = position.latitude;
      double userLng = position.longitude;

      _filteredBusinesses.sort((a, b) {
        double distanceA = _calculateDistanceFromLink(a.locationLink, userLat, userLng);
        double distanceB = _calculateDistanceFromLink(b.locationLink, userLat, userLng);
        return distanceA.compareTo(distanceB);
      });

      setState(() {});
    } catch (e) {
      _showSnackBar('Failed to get location: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  double _calculateDistanceFromLink(String link, double userLat, double userLng) {
    try {
      final regex = RegExp(r'@([-.\d]+),([-.\d]+)');
      final match = regex.firstMatch(link);
      if (match != null) {
        double lat = double.parse(match.group(1)!);
        double lng = double.parse(match.group(2)!);
        return _haversineDistance(userLat, userLng, lat, lng);
      }
      return double.infinity;
    } catch (e) {
      return double.infinity;
    }
  }

  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth's radius in km
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);

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
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _filteredBusinesses.length,
                          itemBuilder: (context, index) {
                            final business = _filteredBusinesses[index];
                            Widget mediaWidget=SizedBox.shrink();
                            if (business.imagePaths.isNotEmpty) {
                             // print(business.imagePaths.first);
                              mediaWidget = _buildMediaWidget(business.imagePaths.first);
                            } else {
                              mediaWidget = Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                              );
                            }

                            return GestureDetector(
                              onTap: () => _navigateToDetailsScreen(business),
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Media Section
                                        SizedBox(
                                          width: 150,
                                          height: 175,
                                          child: mediaWidget,
                                        ),
                                        // Details Section
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Business Name
                                                Text(
                                                  business.name,
                                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                        fontSize: 20,
                                                        color: const Color(0xFF270949),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                ),
                                                // Municipal
                                                if (business.municipal.trim().isNotEmpty) ...[
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.location_on, size: 16, color: Colors.black),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          business.municipal,
                                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                                fontSize: 14,
                                                                color: Colors.black,
                                                              ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                // Event Date
                                                if (business.eventDate.trim().isNotEmpty) ...[
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.event, size: 16, color: Colors.black),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          business.eventDate,
                                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                                fontSize: 14,
                                                                color: Colors.black,
                                                              ),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                // Schedule
                                                if (business.openingHours.trim().isNotEmpty) ...[
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.access_time, size: 16, color: Colors.black),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${context.tr('Schedule')}: ${business.openingHours}',
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                              fontSize: 14,
                                                              color: Colors.black,
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