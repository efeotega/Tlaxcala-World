import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tlaxcala_world/edit_business_screen.dart';
import 'package:tlaxcala_world/firebase_methods.dart';
import 'database_helper.dart';
import 'business_model.dart';

class DeleteBusinessScreen extends StatefulWidget {
  const DeleteBusinessScreen({super.key});

  @override
  _DeleteBusinessScreenState createState() => _DeleteBusinessScreenState();
}

class _DeleteBusinessScreenState extends State<DeleteBusinessScreen> {
  List<Business> _businesses = [];

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

Future<void> _loadBusinesses() async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    // Query Firestore for businesses collection
    QuerySnapshot querySnapshot = await _firestore.collection('businesses').get();
    // Map Firestore documents to Business objects
    setState(() {
      _businesses = querySnapshot.docs.map((doc) {
        return Business.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
    print("Businesses loaded successfully");
  } catch (e) {
    print("Error loading businesses: $e");
  }
}


  // Show confirmation dialog before deleting a business
  void _showDeleteConfirmationDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('Confirm Deletion')),
          content: Text(
              context.tr('Are you sure you want to delete this business?')),
          actions: [
            TextButton(
              child: Text(context.tr('Cancel')),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text(context.tr('Delete')),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteBusiness(id); // Proceed with deletion
              },
            ),
          ],
        );
      },
    );
  }

  // Delete business from the database
  void _deleteBusiness(String id) async {
    await deleteBusiness(context, id);
    _loadBusinesses();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('Business deleted successfully.'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Edit Business'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _businesses.length,
                itemBuilder: (context, index) {
                  final business = _businesses[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditBusinessScreen(
                            business: business,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Text(business.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.red),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditBusinessScreen(
                                    business: business,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _showDeleteConfirmationDialog(business.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                    context); // Return to Business Registration screen
              },
              child: Text(context.tr('Back to Business Registration')),
            ),
          ],
        ),
      ),
    );
  }
}
