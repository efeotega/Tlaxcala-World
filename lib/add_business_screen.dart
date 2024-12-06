import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'dart:typed_data'; // For Uint8List
import 'dart:io' show File; // For File on mobile
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tlaxcala_world/business_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tlaxcala_world/firebase_methods.dart';
import 'package:tlaxcala_world/full_screen_image.dart';

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
  final _municipalController = TextEditingController();
  final _facebookPageController = TextEditingController();
  final _webPageController = TextEditingController();
  final _servicesController = TextEditingController();
  final _addedValueController = TextEditingController();
  final _opinionsController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _promotionsController = TextEditingController();
  final _locationLinkController = TextEditingController();
  final _eventDateController = TextEditingController();
  final _openingHoursController = TextEditingController();
  final _pricesController = TextEditingController();
  final _closingHoursController = TextEditingController();

  bool isLoading = false;
  final bool _isOpen = false;
  String? _selectedBusinessType;
  String? _selectedCategory;
  final List<String> _imagePaths = []; // For mobile
  final List<Uint8List> _imageBytes = []; // For web

  void _addNewItem(BuildContext context, String itemType) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('Add New') + itemType),
          content: TextField(
            controller: controller,
            decoration:
                InputDecoration(hintText: context.tr('Enter') + itemType),
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
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStarRating(String review) {
    int rating = int.tryParse(review) ??
        0; // Assuming review is stored as a number of stars (1-5)
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.yellow,
          ),
          onPressed: () {
            setState(() {
              rating = index + 1;
              _reviewController.text = rating.toString();
            });
          },
        );
      }),
    );
  }

 
  Widget buildBusinessTypeDropdown(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedBusinessType,
            decoration:
                InputDecoration(labelText: context.tr('Type of Business')),
            items: businessCategories.keys
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(
                        context.tr(type)), // Use context.tr for translation
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedBusinessType = value;
                _selectedCategory =
                    null; // Reset category when business type changes
              });
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 30),
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
                  decoration:
                      InputDecoration(labelText: context.tr('Category')),
                  items: businessCategories[_selectedBusinessType]!
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(context
                              .tr(category)), // Use context.tr for translation
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
                icon: const Icon(Icons.add, size: 30),
                onPressed: () => _addNewItem(context, 'Category'),
              ),
            ],
          )
        : const SizedBox(); // Use const for better performance
  }
Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      if (kIsWeb) {
        // For web, save binary data
        for (var file in result.files) {
          if (file.bytes != null) {
            _imageBytes.add(file.bytes!);
          }
        }
      } else {
        // For mobile, save file paths
        for (var file in result.files) {
          if (file.path != null) {
            _imagePaths.add(file.path!);
          }
        }
      }
      setState(() {});
    }
  }

  Future<List<Widget>> _buildImageWidgets(BuildContext context) async {
    List<Widget> widgets = [];
    if (kIsWeb) {
      // Build widgets for web images
      for (var bytes in _imageBytes) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.memory(
                bytes,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }
    } else {
      // Build widgets for mobile images
      for (var path in _imagePaths) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(path),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      // Format the selected time as HH:mm
      final formattedTime = pickedTime.format(context);
      _openingHoursController.text =
          formattedTime; // Set the formatted time to the controller
    }
  }

  Future<void> _selectClosingTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      // Format the selected time as HH:mm
      final formattedTime = pickedTime.format(context);
      _closingHoursController.text =
          formattedTime; // Set the formatted time to the controller
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

  Widget buildClosingHoursField(BuildContext context) {
    return TextFormField(
      controller: _closingHoursController,
      readOnly: true, // Prevent manual text entry
      decoration: InputDecoration(
        labelText: context.tr('Closing Hours'),
      ),
      onTap: () => _selectClosingTime(context), // Show time picker on tap
    );
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
              Text(context.tr('Review (Stars)')),
              _buildStarRating(_reviewController.text),
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
                controller: _municipalController,
                decoration: InputDecoration(labelText: context.tr('Municipal')),
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
                controller: _facebookPageController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                    labelText: context.tr('Facebook Page Link')),
              ),
              TextFormField(
                controller: _webPageController,
                keyboardType: TextInputType.url,
                decoration:
                    InputDecoration(labelText: context.tr('Web Page Link')),
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
              buildClosingHoursField(context),
              // buildOpeningHoursField(context),
              TextFormField(
                controller: _pricesController,
                decoration: InputDecoration(labelText: context.tr('Prices')),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImages,
                child: Text(context.tr('Pick Images')),
              ),
              const SizedBox(
                height: 20,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: FutureBuilder<List<Widget>>(
                  future: _buildImageWidgets(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text('Error loading images');
                    } else {
                      return Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: snapshot.data ?? [],
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      // Save business to database
                      await saveBusinessData(
                          Business(
                            id: '',
                            imagePaths:kIsWeb?_imageBytes: _imagePaths,
                            name: _nameController.text.trim(),
                            businessType: _selectedBusinessType!.trim(),
                            facebookPage: _facebookPageController.text.trim(),
                            website: _webPageController.text.trim(),
                            category: _selectedCategory!.trim(),
                            review: _reviewController.text.trim(),
                            phone: _phoneController.text.trim(),
                            municipal: _municipalController.text.trim(),
                            address: _addressController.text.trim(),
                            services: _servicesController.text.trim(),
                            addedValue: _addedValueController.text.trim(),
                            opinions: _opinionsController.text.trim(),
                            whatsapp: _whatsappController.text.trim(),
                            promotions: _promotionsController.text.trim(),
                            locationLink: _locationLinkController.text.trim(),
                            eventDate: _eventDateController.text.trim(),
                            openingHours: _openingHoursController.text.trim(),
                            closingHours: _closingHoursController.text.trim(),
                            prices: _pricesController.text.trim(),
                          ),
                          context);

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
