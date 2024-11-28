import 'package:flutter/material.dart';
import 'package:tlaxcala_world/business_model.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessDetailsScreen extends StatelessWidget {
  final Business business;

  const BusinessDetailsScreen({super.key, required this.business});

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(business.name),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
             for (String imagePath in business.imagePaths.split(","))
            Image.network(imagePath, height: 200, fit: BoxFit.cover),

            // Business Name and Type
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                business.name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            _detailRow('Type:', business.businessType),
            _detailRow('Category:', business.category),

            // Interactive Sections
            ExpandableSection(
              title: 'Review',
              content: business.review,
            ),
            ExpandableSection(
              title: 'Promotions',
              content: business.promotions,
            ),
            ExpandableSection(
              title: 'Services',
              content: business.services,
            ),

            // Address Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('Phone:', business.phone),
                  _detailRow('Address:', business.address),
                  _detailRow('Schedule:', business.openingHours),
                  _detailRow('Prices:', business.prices),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _launchURL(business.locationLink),
                    icon: const Icon(Icons.map),
                    label: const Text('View on Google Maps'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$title ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? 'Not available')),
        ],
      ),
    );
  }
}

class ExpandableSection extends StatefulWidget {
  final String title;
  final String content;

  const ExpandableSection(
      {super.key, required this.title, required this.content});

  @override
  _ExpandableSectionState createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
          ),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isExpanded ? null : 0,
          child: Visibility(
            visible: _isExpanded,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(widget.content),
            ),
          ),
        ),
      ],
    );
  }
}
