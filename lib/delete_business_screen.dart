import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tlaxcala_world/edit_business_screen.dart';
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

  // Load businesses from the database
  void _loadBusinesses() async {
    final businesses = await DatabaseHelper().getBusinesses();
    setState(() {
      _businesses = businesses.map((map) => Business.fromMap(map)).toList();
    });
  }

  // Delete business from the database
  void _deleteBusiness(int id) async {
    await DatabaseHelper().deleteBusiness(id);
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
              return ListTile(
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
                                builder: (context) =>
                                    EditBusinessScreen(
                                      business: business,
                                    ),
                              ),
                            );
                      },
                    ),
                    const SizedBox(width:10),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteBusiness(business.id!),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Return to Business Registration screen
          },
          child: Text(context.tr('Back to Business Registration')),
        ),
      ],
    ),
  ),
);
}
}
