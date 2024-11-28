import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'business_model.dart';
import 'details_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String businessType;
  final String category;

  const CategoryScreen(
      {super.key, required this.businessType, required this.category});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Business> _filteredBusinesses = [];
  String _searchQuery = '';
  String _sortCriterion = 'Alphabetical';

  @override
  void initState() {
    super.initState();
    _loadFilteredBusinesses();
  }

  void _loadFilteredBusinesses() async {
    final businessesMap = await DatabaseHelper().getBusinesses();
    final businesses =
        businessesMap.map((map) => Business.fromMap(map)).toList();

    setState(() {
      _filteredBusinesses = businesses
          .where((business) =>
              business.businessType == widget.businessType &&
              business.category == widget.category &&
              (business.name
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  _searchQuery.isEmpty))
          .toList();

      _applySorting();
    });
  }

  void _applySorting() {
    setState(() {
      switch (_sortCriterion) {
        case 'Date':
          _filteredBusinesses
              .sort((a, b) => a.eventDate.compareTo(b.eventDate));
          break;
        case 'Municipality':
          _filteredBusinesses.sort((a, b) => a.address.compareTo(b.address));
          break;
        case 'Alphabetical':
          _filteredBusinesses.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Schedule':
          _filteredBusinesses
              .sort((a, b) => a.openingHours.compareTo(b.openingHours));
          break;
      }
    });
  }

  void _navigateToDetailsScreen(Business business) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(business: business),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.businessType} - ${widget.category}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: context.tr('Search'),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _loadFilteredBusinesses();
              },
            ),
          ),
          Column(
            children: [
              if (_filteredBusinesses.isEmpty)
                Center(
                  child: Text(
                    context.tr('No businesses found for this category'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
            ],
          ),
          Column(
            children: [
              if (_filteredBusinesses.isNotEmpty)
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: _filteredBusinesses.length,
                    itemBuilder: (context, index) {
                      final business = _filteredBusinesses[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: GestureDetector(
                          onTap: () => _navigateToDetailsScreen(business),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (String imagePath
                                      in business.imagePaths.split(",").take(1))
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Image.file(
                                        File(imagePath),
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            title: Text(
                              business.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  '${context.tr('Completion Date')}: ${business.eventDate}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${context.tr('Schedule')}: ${business.openingHours}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr('Sort Businesses')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: Text(context.tr('Alphabetical')),
                value: 'Alphabetical',
                groupValue: _sortCriterion,
                onChanged: (value) {
                  setState(() {
                    _sortCriterion = value.toString();
                  });
                  Navigator.pop(context);
                  _applySorting();
                },
              ),
              RadioListTile(
                title: Text(context.tr('Date')),
                value: 'Date',
                groupValue: _sortCriterion,
                onChanged: (value) {
                  setState(() {
                    _sortCriterion = value.toString();
                  });
                  Navigator.pop(context);
                  _applySorting();
                },
              ),
              RadioListTile(
                title: Text(context.tr('Address')),
                value: 'Municipality',
                groupValue: _sortCriterion,
                onChanged: (value) {
                  setState(() {
                    _sortCriterion = value.toString();
                  });
                  Navigator.pop(context);
                  _applySorting();
                },
              ),
              RadioListTile(
                title: Text(context.tr('Schedule')),
                value: 'Schedule',
                groupValue: _sortCriterion,
                onChanged: (value) {
                  setState(() {
                    _sortCriterion = value.toString();
                  });
                  Navigator.pop(context);
                  _applySorting();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
