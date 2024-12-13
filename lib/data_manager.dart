import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class BusinessDataManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Open a Hive box
  Future<Box> _openBox(String name) async {
    if (!Hive.isBoxOpen(name)) {
      return await Hive.openBox(name);
    }
    return Hive.box(name);
  }

  /// Fetch data from Firebase and save locally in Hive
  Future<void> fetchAndSaveBusinessData() async {
    try {
      // Fetch unique business types from Firestore
      final businessTypesSnapshot = await _firestore.collection('businesses').get();
      final businessTypes = businessTypesSnapshot.docs
          .map((doc) => doc['businessType'] as String)
          .toSet()
          .toList();

      // Fetch categories for each business type
      Map<String, List<String>> categoriesByType = {};
      for (String type in businessTypes) {
        final categoriesSnapshot = await _firestore
            .collection('businesses')
            .where('businessType', isEqualTo: type)
            .get();

        final categories = categoriesSnapshot.docs
            .map((doc) => doc['category'] as String)
            .toSet()
            .toList();

        categoriesByType[type] = categories;
      }

      // Save data locally
      final box = await _openBox('business_data');
      box.put('businessTypes', businessTypes);
      box.put('categoriesByType', categoriesByType);
      box.put('lastSynced', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error loading business types and categories from Firebase: $e');
    }
  }

  /// Load business data, preferring Hive unless data is missing or today is Friday
  Future<Map<String, dynamic>> loadBusinessDataFromHive() async {
    final box = await _openBox('business_data');

    // Safely cast business types to List<String>
    final businessTypes = (box.get('businessTypes') as List<dynamic>?)?.cast<String>() ?? [];

    // Safely cast categoriesByType to Map<String, List<String>>
    final rawCategoriesByType = box.get('categoriesByType') as Map<dynamic, dynamic>? ?? {};
    final categoriesByType = rawCategoriesByType.map(
      (key, value) => MapEntry(
        key as String,
        (value as List<dynamic>).cast<String>(),
      ),
    );

    final now = DateTime.now();

    // Check if today is Friday or data is missing
    if (now.weekday == DateTime.friday || businessTypes.isEmpty || categoriesByType.isEmpty) {
      print('Fetching data from Firebase...');
      await fetchAndSaveBusinessData();

      // Reload data after fetching
      return loadBusinessDataFromHive();
    }

    // Return Hive data if valid
    return {
      'businessTypes': businessTypes,
      'categoriesByType': categoriesByType,
    };
  }

  /// Get last sync date
  Future<DateTime?> getLastSyncedDate(String name) async {
    final box = await _openBox(name);
    final lastSynced = box.get('lastSynced');
    return lastSynced != null ? DateTime.parse(lastSynced) : null;
  }
}
