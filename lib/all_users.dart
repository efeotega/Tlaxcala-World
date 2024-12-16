import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tlaxcala_world/feedback/feedback_methods.dart'; // For formatting the createdAt timestamp

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('users').get();

      List<Map<String, dynamic>> usersData = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'email': data['email'],
          'createdAt': (data['createdAt'] as Timestamp).toDate(),
        };
      }).toList();

      setState(() {
        _users = usersData;
        _loading = false;
      });
    } catch (e) {
      //print('Error fetching users: $e');
      showSnackbar(context, 'Error fetching users: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date); // Example: Jan 1, 2024 5:00 PM
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('users_page')),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${context.tr('total_users')}: ${_users.length}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return ListTile(
                        leading: Icon(Icons.person),
                        title: Text(user['email']),
                        subtitle: Text(
                          '${context.tr('created_at')}: ${_formatDate(user['createdAt'])}',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
