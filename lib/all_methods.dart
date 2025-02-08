import 'package:cloud_firestore/cloud_firestore.dart';

/// Logs a visit to Firestore, grouped by date.
Future<void> logAppVisit() async {
  try {
    // Get today's date as a string (e.g., '2024-06-27')
    String today = DateTime.now().toIso8601String().split('T').first;

    // Reference to the document for today
    DocumentReference visitDoc = FirebaseFirestore.instance
        .collection('analytics')
        .doc('visits')
        .collection('daily')
        .doc(today);

    // Use Firestore transactions to avoid race conditions
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(visitDoc);

      if (snapshot.exists) {
        // If document exists, increment the count
        transaction.update(visitDoc, {
          'count': (snapshot['count'] ?? 0) + 1,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        // If document doesn't exist, create it with count = 1
        transaction.set(visitDoc, {
          'count': 1,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    });
    print('Visit logged successfully!');
  } catch (e) {
    print('Failed to log visit: $e');
  }
}
