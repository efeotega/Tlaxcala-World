import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imagePath;

  const FullScreenImagePage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for better viewing
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:  Text(context.tr(''),style: const TextStyle(color:Colors.white),),
        leading: IconButton(
          icon: const Icon(Icons.close,color: Colors.white,),
          onPressed: () {
            Navigator.pop(context); // Close the full-screen page
          },
        ),
      ),
      body: Center(
        child: Image.network(
          imagePath,
          fit: BoxFit.contain, // Ensure the image fits within the screen
        ),
      ),
    );
  }
}
