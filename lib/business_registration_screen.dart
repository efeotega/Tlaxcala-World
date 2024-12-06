import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BusinessRegistrationScreen extends StatelessWidget {
  const BusinessRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Business Registration')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_business),
              label: Text(context.tr('Add Business')),
              onPressed: () {
                // Navigate to Add Business functionality
                Navigator.pushNamed(context, '/addBusiness');
              },
            ),
            const SizedBox(height: 16,),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label:  Text(context.tr('Edit Business')),
              onPressed: () {
                // Navigate to Delete Business functionality
                Navigator.pushNamed(context, '/deleteBusiness');
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label:  Text(context.tr('View Users')),
              onPressed: () {
                // Navigate back to the login screen

                Navigator.pushReplacementNamed(context, '/view-users');
              },
            ),
            const SizedBox(height: 16),
           
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label:  Text(context.tr('Return to Login')),
              onPressed: () {
                // Navigate back to the login screen

                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            
          ],
        ),
      ),
    );
  }
}

