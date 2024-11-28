import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'business_model.dart';
import 'database_helper.dart';

class EditBusinessScreen extends StatefulWidget {
  final Business business;

  const EditBusinessScreen({super.key, required this.business});

  @override
  _EditBusinessScreenState createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends State<EditBusinessScreen> {
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _categoryController;
  late TextEditingController _reviewController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _servicesController;
  late TextEditingController _addedValueController;
  late TextEditingController _promotionsController;
  late TextEditingController _eventDateController;
  late TextEditingController _openingHoursController;
  late TextEditingController _pricesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.business.name);
    _typeController = TextEditingController(text: widget.business.businessType);
    _categoryController = TextEditingController(text: widget.business.category);
    _reviewController = TextEditingController(text: widget.business.review);
    _phoneController = TextEditingController(text: widget.business.phone);
    _addressController = TextEditingController(text: widget.business.address);
    _servicesController = TextEditingController(text: widget.business.services);
    _addedValueController = TextEditingController(text: widget.business.addedValue);
    _promotionsController = TextEditingController(text: widget.business.promotions);
    _eventDateController = TextEditingController(text: widget.business.eventDate);
    _openingHoursController = TextEditingController(text: widget.business.openingHours);
    _pricesController = TextEditingController(text: widget.business.prices);
  }

  Future<void> _saveBusiness() async {
    final updatedBusiness = widget.business.copyWith(
      name: _nameController.text,
      businessType: _typeController.text,
      category: _categoryController.text,
      review: _reviewController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      services: _servicesController.text,
      addedValue: _addedValueController.text,
      promotions: _promotionsController.text,
      eventDate: _eventDateController.text,
      openingHours: _openingHoursController.text,
      prices: _pricesController.text,
    );

    await DatabaseHelper().updateBusiness(updatedBusiness);
     ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(context.tr('Business Updated')),
        ),
      );
    Navigator.pushReplacementNamed(context, '/deleteBusiness'); // Return to previous screen after saving
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
              _buildTextField(context.tr('Business Type'), _typeController),
              _buildTextField(context.tr('Category'), _categoryController),
              _buildTextField(context.tr('Review'), _reviewController),
              _buildTextField(context.tr('Phone Number'), _phoneController),
              _buildTextField(context.tr('Address'), _addressController),
              _buildTextField(context.tr('Services Offered'), _servicesController),
              _buildTextField(context.tr('Added Value'), _addedValueController),
              _buildTextField(context.tr('Promotions'), _promotionsController),
              _buildTextField(context.tr('Completion Date'), _eventDateController),
              _buildTextField(context.tr('Schedule'), _openingHoursController),
              _buildTextField(context.tr('Prices'), _pricesController),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveBusiness,
                child: Text(context.tr('Save')),
              ),
              const SizedBox(height: 15,),
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
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
