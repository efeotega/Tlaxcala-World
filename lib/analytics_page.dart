import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _totalVisits = 0;
  int _selectedDayVisits = 0;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchTotalVisits();
  }

  /// Fetch total visits from all documents
  Future<void> _fetchTotalVisits() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('analytics')
          .doc('visits')
          .collection('daily')
          .get();

      int total = 0;
      for (var doc in snapshot.docs) {
        total += (doc['count'] ?? 0) as int;
      }

      setState(() {
        _totalVisits = total;
      });
    } catch (e) {
      print('Failed to fetch total visits: $e');
    }
  }

  /// Fetch visits for a specific day
  Future<void> _fetchDailyVisits(DateTime date) async {
    try {
      String dateKey = date.toIso8601String().split('T').first;

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('analytics')
          .doc('visits')
          .collection('daily')
          .doc(dateKey)
          .get();

      setState(() {
        _selectedDate = date;
        _selectedDayVisits = snapshot.exists ? (snapshot['count'] ?? 0) : 0;
      });
    } catch (e) {
      print('Failed to fetch daily visits: $e');
    }
  }

  /// Show date picker
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      _fetchDailyVisits(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(context.tr('App Analytics')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Visits
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.blue),
                title:  Text(
                  context.tr('Total Visits'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('$_totalVisits${context.tr(' Visits')}'),
              ),
            ),

            const SizedBox(height: 20),

            // Date Picker Button
            ElevatedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.date_range),
              label: Text(
                _selectedDate == null
                    ? context.tr('Select a Date')
                    : context.tr('Selected')+': ${_selectedDate!.toLocal()}'.split(' ')[0],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // Daily Visits
            if (_selectedDate != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.today, color: Colors.orange),
                  title:  Text(
                    context.tr('Daily Visits'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '$_selectedDayVisits $context.tr( visits on ) ${_selectedDate!.toLocal()}'
                        .split(' ')[0],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
