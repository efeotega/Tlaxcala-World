import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'business_model.dart';

class BusinessDataManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String date = DateTime.now().toIso8601String().split('T').first;

  /// Open a Hive box
  Future<Box> _openBox(String name) async {
    if (!Hive.isBoxOpen(name)) {
      return await Hive.openBox(name);
    }
    return Hive.box(name);
  }

  /// Fetch data from Firebase and save locally in Hive
  Future<void> fetchAndSaveBusinessData(String date) async {
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
      
      final box = await _openBox('business_data_$date');

      box.put('businessTypes', businessTypes);
      box.put('categoriesByType', categoriesByType);
      //box.put('lastSynced',  DateTime.now().toUtc().toIso8601String());
    } catch (e) {
      print('Error loading business types and categories from Firebase: $e');
    }
  } /// Load business data, preferring Hive unless data is missing or today is Friday
  Future<Map<String, dynamic>> loadBusinessDataFromHive() async {
    String date=this.date;
  final box = await _openBox('business_data_$date');


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


  // Check if server was checked today or data is missing
  if (businessTypes.isEmpty || categoriesByType.isEmpty) {
    print("fetching data from firebase...");
    await fetchAndSaveBusinessData(date);

    // Reload data after fetching
    final updatedBox = await _openBox('business_data_$date');

    final updatedBusinessTypes =
        (updatedBox.get('businessTypes') as List<dynamic>?)?.cast<String>() ?? [];
    final updatedRawCategoriesByType = updatedBox.get('categoriesByType') as Map<dynamic, dynamic>? ?? {};
    final updatedCategoriesByType = updatedRawCategoriesByType.map(
      (key, value) => MapEntry(
        key as String,
        (value as List<dynamic>).cast<String>(),
      ),
     );
    // await setServerChecked();
    
    // Ensure data is valid after fetching
    if (updatedBusinessTypes.isNotEmpty && 
    updatedCategoriesByType.isNotEmpty) {
      return {
        'businessTypes': updatedBusinessTypes,
        'categoriesByType': updatedCategoriesByType,
      };
    } else {
     return{
      'businessTypes': updatedBusinessTypes,
        'categoriesByType': updatedCategoriesByType,
     };
    }
    
  }
  else{
    print("Hive box found");
  }
  // Return Hive data if valid
  return {
    'businessTypes': businessTypes,
    'categoriesByType': categoriesByType,
  };
}
  Future<void> loadFilteredBusinessesFromHive(String businessType,String category) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final hiveBoxName = 'filtered_businesses_${businessType}_$category';
  
  try {
    // Determine the data source
    if ((!await Hive.boxExists(hiveBoxName))) {
          print("FETCHING FROM FIREBASE");
      // Fetch from Firebase
      final querySnapshot = await firestore
          .collection('businesses')
          .where('businessType', isEqualTo: businessType)
          .where('category', isEqualTo: category)
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
      //await box.put('lastSynced',  DateTime.now().toUtc().toIso8601String());

      // Update UI
      
    } else {
      print("FETCHING FROM ALREADY SAVED DATA");
      
    }
  } catch (e) {
    print('Error loading filtered businesses: $e');
  }
}

}
