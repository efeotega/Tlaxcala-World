import 'dart:async';
import 'dart:io';
import 'dart:typed_data'; // For Uint8List
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:tlaxcala_world/business_model.dart';
import 'package:tlaxcala_world/feedback/feedback_methods.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tlaxcala_world/firebase_methods.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For uploading files

class AddBusinessScreen extends StatefulWidget {
  const AddBusinessScreen({super.key});

  @override
  _AddBusinessScreenState createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers (unchanged)
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

  // Unified list for media items (URLs as strings, new files as PlatformFile)
  List<dynamic> _mediaItems = [];

  // Helper functions to identify file types
  bool isImageExtension(String ext) {
    return ['jpg', 'jpeg', 'png', 'gif'].contains(ext.toLowerCase());
  }

  bool isVideoExtension(String ext) {
    return ['mp4', 'mov', 'avi', 'mkv'].contains(ext.toLowerCase());
  }

  // Adjusted extension extraction for Firebase Storage URLs
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

  // Pick both images and videos
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

  // Generate thumbnail for videos
  Future<Uint8List?> _generateThumbnail(dynamic mediaItem) async {
    try {
      if (mediaItem is String) {
        // Video URL
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

  // Build widgets for displaying images and video thumbnails
  List<Widget> _buildMediaWidgets(BuildContext context) {
    List<Widget> widgets = [];
    for (int i = 0; i < _mediaItems.length; i++) {
      dynamic item = _mediaItems[i];
      Widget mediaWidget = SizedBox.shrink();

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
              ? Image.memory(
                  item.bytes!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
              : Image.file(
                  File(item.path!),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                );
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

  // Upload file to Firebase Storage and return URL
  Future<String?> _uploadFile(PlatformFile file) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.' + (file.extension ?? '');
      Reference ref = FirebaseStorage.instance.ref().child('business_images').child(fileName);
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

  // Existing methods (unchanged except where noted)
  void _addNewItem(BuildContext context, String itemType) {
    final TextEditingController controller = TextEditingController();
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

  Widget _buildStarRating(String review) {
    int rating = int.tryParse(review) ?? 0;
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
                decoration: InputDecoration(labelText: context.tr('Business Name')),
                validator: (value) => value!.isEmpty ? context.tr('Please enter a business name') : null,
              ),
              buildBusinessTypeDropdown(context),
              buildCategoryDropdown(context),
              Text(context.tr('Review (Stars)')),
              _buildStarRating(_reviewController.text),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: context.tr('Phone Number')),
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
                decoration: InputDecoration(labelText: context.tr('Services Offered')),
              ),
              TextFormField(
                controller: _addedValueController,
                decoration: InputDecoration(labelText: context.tr('Added Value')),
              ),
              TextFormField(
                controller: _opinionsController,
                decoration: InputDecoration(labelText: context.tr('Opinions')),
              ),
              TextFormField(
                controller: _facebookPageController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(labelText: context.tr('Facebook Page Link')),
              ),
              TextFormField(
                controller: _webPageController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(labelText: context.tr('Web Page Link')),
              ),
              TextFormField(
                controller: _promotionsController,
                decoration: InputDecoration(labelText: context.tr('Promotions')),
              ),
              TextFormField(
                controller: _locationLinkController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(labelText: context.tr('Location Link')),
              ),
              TextFormField(
                controller: _eventDateController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: context.tr('Date of Your Event')),
              ),
              buildOpeningHoursField(context),
              buildClosingHoursField(context),
              TextFormField(
                controller: _pricesController,
                decoration: InputDecoration(labelText: context.tr('Prices')),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickMedia,
                child: Text(context.tr('Pick Media')),
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
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      if (!isLocationLinkValid(_locationLinkController.text.trim())) {
                        showSnackbar(context, context.tr('location link is invalid'));
                        setState(() {
                          isLoading = false;
                        });
                        return;
                      }

                      // Upload all media files and collect URLs
                      List<String> imagePaths = [];
                      List<Future<String?>> uploadFutures = [];

                      for (var item in _mediaItems) {
                        if (item is String) {
                          imagePaths.add(item); // Shouldn't happen in AddBusinessScreen, but kept for safety
                        } else if (item is PlatformFile) {
                          uploadFutures.add(_uploadFile(item));
                        }
                      }

                      List<String?> newUrls = await Future.wait(uploadFutures);
                      imagePaths.addAll(newUrls.where((url) => url != null).cast<String>());

                      await saveBusinessData(
                        Business(
                          id: '',
                          imagePaths: imagePaths, // Pass list of URLs
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
                        context,
                      );
                      setState(() {
                        isLoading = false;
                      });
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