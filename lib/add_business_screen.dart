import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tlaxcala_world/business_model.dart';
import 'package:tlaxcala_world/full_screen_image.dart';
import 'database_helper.dart';

class AddBusinessScreen extends StatefulWidget {
  const AddBusinessScreen({super.key});

  @override
  _AddBusinessScreenState createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _reviewController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _servicesController = TextEditingController();
  final _addedValueController = TextEditingController();
  final _opinionsController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _promotionsController = TextEditingController();
  final _locationLinkController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _openingHoursController = TextEditingController();
  final _pricesController = TextEditingController();
  bool isLoading = false;
  String? _selectedBusinessType;
String? _selectedCategory;

void _addNewItem(BuildContext context, String itemType) {
  final TextEditingController controller = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(context.tr('Add New')+itemType),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: context.tr('Enter')+itemType),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.tr('Cancel')),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  if (itemType == 'Business Type') {
                    businessCategories[controller.text] = [];
                    _selectedBusinessType = controller.text;
                  } else if (itemType == 'Category' &&
                      _selectedBusinessType != null) {
                    businessCategories[_selectedBusinessType]!
                        .add(controller.text);
                    _selectedCategory = controller.text;
                  }
                });
                Navigator.of(context).pop();
              }
            },
            child: Text('Add'),
          ),
        ],
      );
    },
  );
}

Widget buildBusinessTypeDropdown(BuildContext context) {
  return Row(
    children: [
      Expanded(
        child: DropdownButtonFormField<String>(
          value: _selectedBusinessType,
          decoration: InputDecoration(labelText: context.tr('Type of Business')),
          items: businessCategories.keys
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(context.tr(type)), // Use context.tr for translation
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedBusinessType = value;
              _selectedCategory = null; // Reset category when business type changes
            });
          },
        ),
      ),
      IconButton(
        icon: Icon(Icons.add, size: 30),
        onPressed: () => _addNewItem(context, 'Business Type'),
      ),
    ],
  );
}

Widget buildCategoryDropdown(BuildContext context) {
  return _selectedBusinessType != null
      ? Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: context.tr('Category')),
                items: businessCategories[_selectedBusinessType]!
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(context.tr(category)), // Use context.tr for translation
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.add, size: 30),
              onPressed: () => _addNewItem(context, 'Category'),
            ),
          ],
        )
      : const SizedBox(); // Use const for better performance
}

  final List<String> _imagePaths = []; // Store multiple image paths
Future<void> _selectTime(BuildContext context) async {
  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (pickedTime != null) {
    // Format the selected time as HH:mm
    final formattedTime = pickedTime.format(context);
    _openingHoursController.text = formattedTime; // Set the formatted time to the controller
  }
}

Widget buildOpeningHoursField(BuildContext context) {
  return TextFormField(
    controller: _openingHoursController,
    readOnly: true, // Prevent manual text entry
    decoration: InputDecoration(
      labelText: context.tr('Opening Hours'),
    ),
    onTap: () => _selectTime(context), // Show time picker on tap
  );
}
  Future<void> _pickImage() async {
    if (_imagePaths.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only select up to 3 images'),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePaths.add(pickedFile.path); // Add the image path to the list
       
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index); // Remove an image from the list
    });
  }


  Map<String, List<String>> businessCategories = {
    'Cinema': ['Billboards', 'Cinemas'],
    'Hotels': ['Hotels', 'Motels', 'Ranches'],
    'Restaurants': ['Cafes', 'Restaurants', 'Cusquerias'],
    'Clubs and Bars': ['Clubs', 'Cantabar', 'Cantinas', 'Bars', 'Botanero'],
    'Sports': [
      'Soccer',
      'Basketball',
      'Tennis',
      'Archery',
      'Baseball',
      'Wrestling',
      'Gym'
    ],
    'Art and Culture': ['Crafts', 'Cultural'],
    'Conferences and Exhibitions': ['Sporting', 'Cultural', 'Academic'],
    'Schools': [
      'Nursery School',
      'Kindergarten',
      'Secondary School',
      'High School',
      'University',
      'Courses'
    ],
    'Gyms': ['Yoga', 'Zumba', 'Specialty'],
    'Parties': ['Patron Saints', 'Municipal', 'Private'],
    'Theater': ['Family', 'Children', 'Teenagers', 'Adults'],
    'Events': ['Sports', 'Cultural', 'Art', 'Bullfights', 'Charreadas'],
    'Dances and Concerts': ['Dances', 'Concerts'],
    'Doctors and Hospitals': ['Specialties', 'Hospitals', 'Private Doctors'],
    'Consultancies': [
      'Legal',
      'Entrepreneurship',
      'Tax and Accounting',
      'Business'
    ],
    'Beauty': ['Spa', 'Waxing', 'Pedicure', 'Barbershops', 'Nails'],
    'Service': ['Photos and Videos', 'Weddings', 'XV', 'Real Estate'],
    'Newspapers': ['Sports', 'Local', 'National'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Add Business')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.text,
                decoration:
                    InputDecoration(labelText: context.tr('Business Name')),
                validator: (value) => value!.isEmpty
                    ? context.tr('Please enter a business name')
                    : null,
              ),
                buildBusinessTypeDropdown(context),
      buildCategoryDropdown(context),
              TextFormField(
                controller: _reviewController,
                decoration: InputDecoration(labelText: context.tr('Review')),
              ),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration:
                    InputDecoration(labelText: context.tr('Phone Number')),
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: context.tr('Address')),
              ),
              TextFormField(
                controller: _servicesController,
                decoration:
                    InputDecoration(labelText: context.tr('Services Offered')),
              ),
              TextFormField(
                controller: _addedValueController,
                decoration:
                    InputDecoration(labelText: context.tr('Added Value')),
              ),
              TextFormField(
                controller: _opinionsController,
                decoration: InputDecoration(labelText: context.tr('Opinions')),
              ),
              TextFormField(
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: context.tr('WhatsApp')),
              ),
              TextFormField(
                controller: _promotionsController,
                decoration:
                    InputDecoration(labelText: context.tr('Promotions')),
              ),
              TextFormField(
                controller: _locationLinkController,
                keyboardType: TextInputType.url,
                decoration:
                    InputDecoration(labelText: context.tr('Location Link')),
              ),
              TextFormField(
                controller: _eventDateController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    labelText: context.tr('Date of Your Event')),
              ),
              buildOpeningHoursField(context),
              TextFormField(
                controller: _pricesController,
                decoration: InputDecoration(labelText: context.tr('Prices')),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text(context.tr('Pick Image')),
              ),
              const SizedBox(height: 20,),
              if(_imagePaths.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    
                  },
                  child:  SizedBox(
                    height: 120,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullScreenImagePage(imagePath: _imagePaths[index]),
                              ),
                            );
                        },
                        child: Image.file(
                          File(_imagePaths[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: const CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.close, color: Colors.white, size: 15),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
                ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading=true;
                      });
                      // Save business to database
                      await DatabaseHelper().addBusiness(
                        Business(
                          imagePaths: _imagePaths.join(","),
                          name: _nameController.text.trim(),
                          businessType: _selectedBusinessType!.trim(),
                          category: _selectedCategory!.trim(),
                          review: _reviewController.text.trim(),
                          phone: _phoneController.text.trim(),
                          address: _addressController.text.trim(),
                          services: _servicesController.text.trim(),
                          addedValue: _addedValueController.text.trim(),
                          opinions: _opinionsController.text.trim(),
                          whatsapp: _whatsappController.text.trim(),
                          promotions: _promotionsController.text.trim(),
                          locationLink: _locationLinkController.text.trim(),
                          eventDate: _eventDateController.text.trim(),
                          openingHours: _openingHoursController.text.trim(),
                          prices: _pricesController.text.trim(),
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context
                              .tr('You have been successfully registered.')),
                        ),
                      );

                      Navigator.pop(context);
                    }
                  },
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : Text(context.tr('Sign Up')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
