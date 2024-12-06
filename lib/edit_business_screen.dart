import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tlaxcala_world/full_screen_image.dart';
import 'business_model.dart';
import 'database_helper.dart';
import 'package:image_picker/image_picker.dart';

class EditBusinessScreen extends StatefulWidget {
  final Business business;

  const EditBusinessScreen({super.key, required this.business});

  @override
  _EditBusinessScreenState createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends State<EditBusinessScreen> {
  late TextEditingController _nameController;
  late TextEditingController _reviewController;
  late TextEditingController _eventDateController;
  late TextEditingController _openingHoursController;
  late TextEditingController _closingHoursController;
  late TextEditingController _addressController;
  late TextEditingController _locationLinkController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addedValueController;
  late TextEditingController _opinionController;
  late TextEditingController _servicesController;
  late TextEditingController _promotionsController;
  late TextEditingController _facebookController;
  String? _selectedBusinessType;
  String? _selectedCategory;
  late TextEditingController _websiteController;
  List<String> _imagePaths = []; // For mobile
  final List<Uint8List> _imageBytes = []; // For web
  late TextEditingController _municipalController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.business.name);
    _reviewController = TextEditingController(text: widget.business.review);
    _eventDateController =
        TextEditingController(text: widget.business.eventDate);
    _openingHoursController =
        TextEditingController(text: widget.business.openingHours);
    _closingHoursController =
        TextEditingController(text: widget.business.closingHours);
    _addressController = TextEditingController(text: widget.business.address);
    _municipalController =
        TextEditingController(text: widget.business.municipal);
    _locationLinkController =
        TextEditingController(text: widget.business.locationLink);
    _servicesController = TextEditingController(text: widget.business.services);
    _promotionsController =
        TextEditingController(text: widget.business.promotions);
    _facebookController =
        TextEditingController(text: widget.business.facebookPage);
    _opinionController = TextEditingController(text: widget.business.opinions);
    _addedValueController =
        TextEditingController(text: widget.business.addedValue);
    _phoneNumberController = TextEditingController(text: widget.business.phone);
    _websiteController = TextEditingController(text: widget.business.website);
    _selectedBusinessType = widget.business.businessType;
    _selectedCategory = widget.business.category;

    // Split the imagePaths string into a list of file paths
    _imagePaths = widget.business.imagePaths.cast<String>();

    // Check the opening hours for the Open/Close status
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

  Future<void> _saveBusiness() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Create the updated business object
    final updatedBusiness = widget.business.copyWith(
      name: _nameController.text.trim(),
      review: _reviewController.text.trim(),
      eventDate: _eventDateController.text.trim(),
      openingHours: _openingHoursController.text.trim(),
      closingHours: _closingHoursController.text.trim(),
      address: _addressController.text.trim(),
      municipal: _municipalController.text.trim(),
      locationLink: _locationLinkController.text.trim(),
      services: _servicesController.text.trim(),
      promotions: _promotionsController.text.trim(),
      facebookPage: _facebookController.text.trim(),
      website: _websiteController.text.trim(),
      imagePaths: kIsWeb ? _imageBytes : _imagePaths, // Join the image paths
      phone: _phoneNumberController.text.trim(),
      addedValue: _addedValueController.text.trim(),
      opinions: _opinionController.text.trim(),
    );

    try {
      // Assume `businessId` or `documentId` is stored in the `Business` object
      await _firestore.collection('businesses').doc(widget.business.id).update({
        'name': updatedBusiness.name,
        'review': updatedBusiness.review,
        'eventDate': updatedBusiness.eventDate,
        'openingHours': updatedBusiness.openingHours,
        'closingHours': updatedBusiness.closingHours,
        'address': updatedBusiness.address,
        'municipal': updatedBusiness.municipal,
        'locationLink': updatedBusiness.locationLink,
        'services': updatedBusiness.services,
        'promotions': updatedBusiness.promotions,
        'facebookPage': updatedBusiness.facebookPage,
        'website': updatedBusiness.website,
        'imagePaths': updatedBusiness.imagePaths,
        'phone': updatedBusiness.phone,
        'addedValue': updatedBusiness.addedValue,
        'opinions': updatedBusiness.opinions,
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Business Updated Successfully')),
      );

      // Navigate to another page after updating
      Navigator.pushReplacementNamed(context, '/deleteBusiness');
    } catch (e) {
      // Handle errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update business: $e')),
      );
    }
  }

  Future<bool> _isPortrait(String imagePath) async {
    final completer = Completer<ImageInfo>();
    final image = Image.network(
      imagePath,
      errorBuilder: (context, error, stackTrace) {
        return Image.file(
          File(imagePath),
        );
      },
    );

    final ImageStream stream = image.image.resolve(const ImageConfiguration());
    final listener = ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    });

    stream.addListener(listener);
    final ImageInfo imageInfo = await completer.future;
    stream.removeListener(listener);

    return imageInfo.image.width < imageInfo.image.height;
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      if (kIsWeb) {
        // For web, save binary data
        _imagePaths.clear();
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
      if (_imagePaths.isEmpty) {
        for (var bytes in _imageBytes) {
          widgets.add(Padding(
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
          ));
        }
      }
      for (var path in _imagePaths) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  path,
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    for (var bytes in _imageBytes) {
                      return Image.memory(
                        bytes,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                )),
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
                child: Image.network(
                  path,
                  width: 100,
                  height: 100,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.file(
                      File(path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  },
                )),
          ),
        );
      }
    }
    return widgets;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Edit Business')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(context.tr('Business Name'), _nameController),
              const SizedBox(height: 16),
              buildBusinessTypeDropdown(context),
              const SizedBox(
                height: 16,
              ),
              buildCategoryDropdown(context),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Text(context.tr('Photos')),
                  Spacer(),
                  TextButton(
                      onPressed: () {
                        _pickImages();
                      },
                      child: Text(context.tr('Change Photos')))
                ],
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
                      print(snapshot.error);
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
              const SizedBox(height: 16),
              Text(context.tr('Review (Stars)')),
              _buildStarRating(_reviewController.text),
              const SizedBox(height: 16),
              _buildTextField(
                  context.tr('Completion Date'), _eventDateController),
              const SizedBox(height: 16),
              // _buildOpenCloseSwitch(),
              buildOpeningHoursField(context),
              buildClosingHoursField(context),
              const SizedBox(height: 16),
              _buildTextField(context.tr('Address'), _addressController),
              _buildTextField(context.tr('Municipal'), _municipalController),
              _buildTextField(
                  context.tr('Location Link'), _locationLinkController),
              _buildTextField(
                  context.tr('Phone Number'), _phoneNumberController),
              _buildTextField(context.tr('Added Value'), _addedValueController),
              _buildTextField(context.tr('Opinion'), _opinionController),
              _buildTextField(
                  context.tr('Services Offered'), _servicesController),
              _buildTextField(context.tr('Promotions'), _promotionsController),
              _buildTextField(
                  context.tr('Facebook Page Link'), _facebookController),
              _buildTextField(context.tr('Website Link'), _websiteController),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveBusiness,
                child: Text(context.tr('Save')),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.tr('Cancel')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
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
}
