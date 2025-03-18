import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For uploading files
import 'package:tlaxcala_world/feedback/feedback_methods.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'business_model.dart';

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
  late TextEditingController _municipalController;
  bool isLoading=false;

  // List to hold both existing URLs (strings) and new files (PlatformFile)
  List<dynamic> _mediaItems = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.business.name);
    _reviewController = TextEditingController(text: widget.business.review);
    _eventDateController = TextEditingController(text: widget.business.eventDate);
    _openingHoursController = TextEditingController(text: widget.business.openingHours);
    _closingHoursController = TextEditingController(text: widget.business.closingHours);
    _addressController = TextEditingController(text: widget.business.address);
    _municipalController = TextEditingController(text: widget.business.municipal);
    _locationLinkController = TextEditingController(text: widget.business.locationLink);
    _servicesController = TextEditingController(text: widget.business.services);
    _promotionsController = TextEditingController(text: widget.business.promotions);
    _facebookController = TextEditingController(text: widget.business.facebookPage);
    _opinionController = TextEditingController(text: widget.business.opinions);
    _addedValueController = TextEditingController(text: widget.business.addedValue);
    _phoneNumberController = TextEditingController(text: widget.business.phone);
    _websiteController = TextEditingController(text: widget.business.website);
    _selectedBusinessType = widget.business.businessType;
    _selectedCategory = widget.business.category;

    // Initialize _mediaItems directly from imagePaths
    _mediaItems = List.from(widget.business.imagePaths);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final formattedTime = pickedTime.format(context);
      _openingHoursController.text = formattedTime;
    }
  }

  Future<void> _selectClosingTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final formattedTime = pickedTime.format(context);
      _closingHoursController.text = formattedTime;
    }
  }

  Widget buildOpeningHoursField(BuildContext context) {
    return TextFormField(
      controller: _openingHoursController,
      readOnly: true,
      decoration: InputDecoration(labelText: context.tr('Opening Hours')),
      onTap: () => _selectTime(context),
    );
  }

  Widget buildClosingHoursField(BuildContext context) {
    return TextFormField(
      controller: _closingHoursController,
      readOnly: true,
      decoration: InputDecoration(labelText: context.tr('Closing Hours')),
      onTap: () => _selectClosingTime(context),
    );
  }

  bool isLocationLinkValid(String link) {
    try {
      final regex = RegExp(
          r'https:\/\/www\.google\.com\/maps\/place\/[^@]+\/@([-.\d]+),([-.\d]+)(?:,\d+z)?');
      final match = regex.firstMatch(link);
      if (match == null) return false;
      double lat = double.parse(match.group(1)!);
      double lng = double.parse(match.group(2)!);
      return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    } catch (e) {
      print('Error validating link: $e');
      return false;
    }
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: kIsWeb ? FileType.custom : FileType.media,
      allowedExtensions: kIsWeb
          ? ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov', 'avi', 'mkv']
          : null,
    );

    if (result != null) {
      setState(() {
        _mediaItems.addAll(result.files);
      });
    }
  }

  bool isImageExtension(String ext) {
    return ['jpg', 'jpeg', 'png', 'gif'].contains(ext.toLowerCase());
  }

  bool isVideoExtension(String ext) {
    return ['mp4', 'mov', 'avi', 'mkv'].contains(ext.toLowerCase());
  }

  /// Generates a thumbnail for a video URL or file path
  Future<Uint8List?> _generateThumbnail(dynamic mediaItem) async {
    try {
      if (mediaItem is String) {
        // Existing video URL
        return await VideoThumbnail.thumbnailData(
          video: mediaItem,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 128,
          quality: 25,
        );
      } else if (mediaItem is PlatformFile && !kIsWeb && mediaItem.path != null) {
        // New video file
        return await VideoThumbnail.thumbnailData(
          video: mediaItem.path!,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 128,
          quality: 25,
        );
      }
      return null;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

 String _getExtension(dynamic item) {
  if (item is String) {
    // Split by '?' to separate path from query parameters, take the path part
    String pathPart = item.split('?').first;
    // Split by '.' and take the last part that looks like an extension
    List<String> parts = pathPart.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  } else if (item is PlatformFile) {
    return item.extension?.toLowerCase() ?? '';
  }
  return '';
}

  List<Widget> _buildMediaWidgets(BuildContext context) {
    List<Widget> widgets = [];

    for (int i = 0; i < _mediaItems.length; i++) {
      dynamic item = _mediaItems[i];
      print(item);
      Widget mediaWidget=SizedBox.shrink();

      String extension = _getExtension(item);

      if (isImageExtension(extension)) {
        if (item is String) {
          // Existing image URL
          mediaWidget = Image.network(
            item,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
          );
        } else if (item is PlatformFile) {
          // New image file
          mediaWidget = kIsWeb
              ? Image.memory(item.bytes!, width: 100, height: 100, fit: BoxFit.cover)
              : Image.file(File(item.path!), width: 100, height: 100, fit: BoxFit.cover);
        }
      } else if (isVideoExtension(extension)) {
        mediaWidget = FutureBuilder<Uint8List?>(
          future: _generateThumbnail(item),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
              return Stack(
                children: [
                  Image.memory(
                    snapshot.data!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  
                ],
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: 100,
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            } else {
              return const SizedBox(
                width: 100,
                height: 100,
                child: Icon(Icons.video_library, size: 50, color: Colors.grey),
              );
            }
          },
        );
      } else {
        mediaWidget = const SizedBox(
          width: 100,
          height: 100,
          child: Icon(Icons.error),
        );
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: mediaWidget,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      _mediaItems.removeAt(i);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  /// Uploads a file to Firebase Storage and returns the download URL
  Future<String?> _uploadFile(PlatformFile file) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.' + (file.extension ?? '');
      Reference ref = FirebaseStorage.instance.ref().child('business_media').child(fileName);
      UploadTask uploadTask;
      if (kIsWeb) {
        uploadTask = ref.putData(file.bytes!);
      } else {
        uploadTask = ref.putFile(File(file.path!));
      }
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<void> _saveBusiness() async {
    if (!isLocationLinkValid(_locationLinkController.text.trim())) {
      showSnackbar(context, context.tr('location link is invalid'));
      return;
    }
    setState(() {
      isLoading=true;
    });
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    List<dynamic> updatedImagePaths = [];
    List<Future<String?>> uploadFutures = [];

    for (var item in _mediaItems) {
      if (item is String) {
        updatedImagePaths.add(item);
      } else if (item is PlatformFile) {
        uploadFutures.add(_uploadFile(item));
      }
    }

    List<String?> newUrls = await Future.wait(uploadFutures);
    updatedImagePaths.addAll(newUrls.where((url) => url != null).cast<String>());

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
      imagePaths: updatedImagePaths,
      phone: _phoneNumberController.text.trim(),
      addedValue: _addedValueController.text.trim(),
      opinions: _opinionController.text.trim(),
    );

    try {
      await firestore.collection('businesses').doc(widget.business.id).update({
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business Updated Successfully')),
      );
      Navigator.pushReplacementNamed(context, '/deleteBusiness');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update business: $e')),
      );
      setState(() {
      isLoading=false;
    });
    }
  }

  Map<String, List<String>> businessCategories = {
    'Cinema': ['Billboards', 'Cinemas'],
    'Hotels': ['Hotels', 'Motels', 'Ranches'],
    'Restaurants': ['Cafes', 'Restaurants', 'Cusquerias'],
    'Clubs and Bars': ['Clubs', 'Cantabar', 'Cantinas', 'Bars', 'Botanero'],
    'Sports': ['Soccer', 'Basketball', 'Tennis', 'Archery', 'Baseball', 'Wrestling', 'Gym'],
    'Art and Culture': ['Crafts', 'Cultural'],
    'Conferences and Exhibitions': ['Sporting', 'Cultural', 'Academic'],
    'Schools': ['Nursery School', 'Kindergarten', 'Secondary School', 'High School', 'University', 'Courses'],
    'Gyms': ['Yoga', 'Zumba', 'Specialty'],
    'Parties': ['Patron Saints', 'Municipal', 'Private'],
    'Theater': ['Family', 'Children', 'Teenagers', 'Adults'],
    'Events': ['Sports', 'Cultural', 'Art', 'Bullfights', 'Charreadas'],
    'Dances and Concerts': ['Dances', 'Concerts'],
    'Doctors and Hospitals': ['Specialties', 'Hospitals', 'Private Doctors'],
    'Consultancies': ['Legal', 'Entrepreneurship', 'Tax and Accounting', 'Business'],
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
            decoration: InputDecoration(labelText: context.tr('Type of Business')),
            items: businessCategories.keys
                .map((type) => DropdownMenuItem(value: type, child: Text(context.tr(type))))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedBusinessType = value;
                _selectedCategory = null;
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
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('Add New') + itemType),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: context.tr('Enter') + itemType),
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
                    } else if (itemType == 'Category' && _selectedBusinessType != null) {
                      businessCategories[_selectedBusinessType]!.add(controller.text);
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
                  decoration: InputDecoration(labelText: context.tr('Category')),
                  items: businessCategories[_selectedBusinessType]!
                      .map((category) => DropdownMenuItem(value: category, child: Text(context.tr(category))))
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
        : const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Edit Business'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(context.tr('Business Name'), _nameController),
              const SizedBox(height: 16),
              buildBusinessTypeDropdown(context),
              const SizedBox(height: 16),
              buildCategoryDropdown(context),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(context.tr('Media')),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickMedia,
                    child: Text(context.tr('Change Media')),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _buildMediaWidgets(context),
                ),
              ),
              const SizedBox(height: 16),
              Text(context.tr('Review (Stars)')),
              _buildStarRating(_reviewController.text),
              const SizedBox(height: 16),
              _buildTextField(context.tr('Completion Date'), _eventDateController),
              const SizedBox(height: 16),
              buildOpeningHoursField(context),
              buildClosingHoursField(context),
              const SizedBox(height: 16),
              _buildTextField(context.tr('Address'), _addressController),
              _buildTextField(context.tr('Municipal'), _municipalController),
              _buildTextField(context.tr('Location Link'), _locationLinkController),
              _buildTextField(context.tr('Phone Number'), _phoneNumberController),
              _buildTextField(context.tr('Added Value'), _addedValueController),
              _buildTextField(context.tr('Opinion'), _opinionController),
              _buildTextField(context.tr('Services Offered'), _servicesController),
              _buildTextField(context.tr('Promotions'), _promotionsController),
              _buildTextField(context.tr('Facebook Page Link'), _facebookController),
              _buildTextField(context.tr('Website Link'), _websiteController),
              const SizedBox(height: 16),
             isLoading?const SizedBox(height: 20,width:20,child: CircularProgressIndicator(),): ElevatedButton(onPressed: _saveBusiness, child: Text(context.tr('Save'))),
              const SizedBox(height: 15),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('Cancel'))),
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
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget _buildStarRating(String review) {
    int rating = int.tryParse(review) ?? 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(index < rating ? Icons.star : Icons.star_border, color: Colors.yellow),
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