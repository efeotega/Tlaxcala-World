import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tlaxcala_world/business_model.dart';
import 'package:tlaxcala_world/feedback/feedback_methods.dart';

Future<dynamic> loginUser(
    String email, String password, BuildContext context) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  try {
    // Sign in user with email and password
    await auth.signInWithEmailAndPassword(email: email, password: password);
    showSnackbar(context, context.tr("Logged in successfully"));
    Navigator.pushReplacementNamed(context, '/menu');
    var user = FirebaseAuth.instance.currentUser;
    String userEmail = user!.email!;
    if (userEmail == "admin@mundotlaxcala.com") {
      Navigator.pushReplacementNamed(context, '/businessRegistration');
    } else {
      Navigator.pushReplacementNamed(context, '/menu');
    }
    return user;
  } on FirebaseAuthException catch (e) {
    // Handle Firebase-specific errors
    if (e.code == 'user-not-found') {
      showSnackbar(context, context.tr('No user found for that email.'));
    } else if (e.code == 'wrong-password') {
      showSnackbar(context, context.tr('Wrong password provided.'));
    }
    return null;
  } catch (e) {
    // Handle general errors
    print('An error occurred during login: $e');
    return null;
  }
}

Future<dynamic> createUser(
    String email, String password, BuildContext context) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    // Create user with email and password
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Save user email to Firestore after successful authentication
    await firestore.collection('users').doc(userCredential.user?.uid).set({
      'email': email,
      'createdAt': DateTime.now(),
    });

    showSnackbar(context, context.tr("Registration successfull"));
    Navigator.pushReplacementNamed(context, '/login');
    var user = FirebaseAuth.instance.currentUser;
    return user;
  } on FirebaseAuthException catch (e) {
    // Handle Firebase-specific errors
    if (e.code == 'email-already-in-use') {
      showSnackbar(context, context.tr('This account already exists'));
    } else if (e.code == 'weak-password') {
      showSnackbar(
          context,
          context.tr(
              'The password is too weak. Password should be at least six digits'));
    }
    return null;
  } catch (e) {
    // Handle general errors
    print('An error occurred during user creation: $e');
    return null;
  }
}
Future<void> deleteBusiness(BuildContext context,String businessId) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    // Delete the document with the specified ID from the 'businesses' collection
    await firestore.collection('businesses').doc(businessId).delete();

    showSnackbar(context,"Business deleted successfully.");
  } catch (e) {
    print("Failed to delete business: $e");
  }
}
Future<void> saveBusinessData(Business business, BuildContext context) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  try {
    // Upload images and retrieve URLs
    // On mobile, business.imagePaths is expected to be List<String> (file paths)
    // On web, it might be List<Uint8List> (binary data)
    List<dynamic> imagePaths = business.imagePaths;
    List<String> uploadedImageUrls = [];

    for (var image in imagePaths) {
      String fileName;
      UploadTask uploadTask;
      Reference storageRef;
      TaskSnapshot snapshot;
      
      if (kIsWeb) {
        // On web: image is assumed to be Uint8List
        Uint8List imageData = image as Uint8List;
        // You may want to generate a unique file name, for example using a timestamp:
        fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        storageRef = storage.ref().child('business_images/$fileName');
        uploadTask = storageRef.putData(imageData);
      } else {
        // On mobile: image is assumed to be a file path (String)
        String path = image as String;
        File file = File(path);
        fileName = path.split('/').last;
        storageRef = storage.ref().child('business_images/$fileName');
        uploadTask = storageRef.putFile(file);
      }

      snapshot = await uploadTask;
      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      uploadedImageUrls.add(downloadUrl);
    }

    // Save business data to Firestore
    // Create a new document reference
    final docRef = firestore.collection('businesses').doc();

    // Save business data with the document ID
    await docRef.set({
      'id': docRef.id, // Add the document ID as 'id' field
      'name': business.name,
      'businessType': business.businessType,
      'facebookPage': business.facebookPage,
      'website': business.website,
      'category': business.category,
      'review': business.review,
      'phone': business.phone,
      'municipal': business.municipal,
      'address': business.address,
      'services': business.services,
      'addedValue': business.addedValue,
      'opinions': business.opinions,
      'whatsapp': business.whatsapp,
      'promotions': business.promotions,
      'locationLink': business.locationLink,
      'eventDate': business.eventDate,
      'openingHours': business.openingHours,
      'closingHours': business.closingHours,
      'prices': business.prices,
      'imagePaths': uploadedImageUrls,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Business successfully registered."),
      ),
    );
    Navigator.pop(context);
  } catch (e) {
    print("Error saving business data: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Error saving business data."),
      ),
    );
  }
}
