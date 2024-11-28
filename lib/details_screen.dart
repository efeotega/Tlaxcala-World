import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tlaxcala_world/full_screen_image.dart';
import 'business_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsScreen extends StatelessWidget {
  final Business business;

  const DetailsScreen({super.key, required this.business});

  Future<void> _launchLocation(String locationLink) async {
    if (await canLaunchUrl(Uri.parse(locationLink))) {
      await launchUrl(Uri.parse(locationLink));
    } else {
      throw 'Could not open the location';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(business.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business Name and Type
              Text(
                business.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${business.businessType} - ${business.category}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                     
                    ),
              ),
              const SizedBox(height: 16),

              // Information Cards with Icons
              _buildInfoCard(Icons.star, context.tr('Review'), business.review,context),
              _buildInfoCard(Icons.phone, context.tr('Phone'), business.phone,context),
              _buildInfoCard(Icons.location_on, context.tr('Address'), business.address,context),
              _buildInfoCard(Icons.build, context.tr('Services'), business.services,context),
              _buildInfoCard(Icons.add, context.tr('Added Value'), business.addedValue,context),
              _buildInfoCard(Icons.local_offer, context.tr('Promotions'), business.promotions,context),
              _buildInfoCard(Icons.calendar_today, context.tr('Completion Date'), business.eventDate,context),
              _buildInfoCard(Icons.schedule, context.tr('Schedule'), business.openingHours,context),
              _buildInfoCard(Icons.attach_money, context.tr('Prices'), business.prices,context),

              const SizedBox(height: 16),

              // Photos Section
              Text(
                context.tr('Photos'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
             SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: business.imagePaths.split(",").map((imagePath) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenImagePage(imagePath: imagePath),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.file(
              File(imagePath),
              width: 150,
              height: 150, // Ensure a consistent size
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }).toList(),
  ),
),
 const SizedBox(height: 16),

              // Location Button
              ElevatedButton.icon(
                onPressed: () => _launchLocation(business.locationLink),
                icon: const Icon(Icons.map),
                label: Text(context.tr('Open Location in Google Maps')),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Back Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/menu');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(context.tr('Back to Menu')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Information Cards with Icons
  Widget _buildInfoCard(IconData icon, String title, String content,BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
