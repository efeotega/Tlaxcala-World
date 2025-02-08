import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:tlaxcala_world/business_model.dart';
import 'package:tlaxcala_world/feedback/feedback_methods.dart';
import 'package:tlaxcala_world/full_screen_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ShowLinkDetailsScreen extends StatelessWidget {
  final Business business;

  const ShowLinkDetailsScreen({super.key, required this.business});
  Future<void> downloadAndShareMultipleImages(
      String imageUrl, String text) async {
    try {
      if (kIsWeb) {
        Share.share(text);
      } else {
        if (imageUrl.isEmpty) {
          Share.share(text);
        } else {
// Create a list to store downloaded file paths
          final List<XFile> files = [];

          // Download each image and save it temporarily
          final response = await http.get(Uri.parse(imageUrl));
          final tempDir = await getTemporaryDirectory();
          final filePath =
              '${tempDir.path}/${Uri.parse(imageUrl).pathSegments.last}';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          // Add the file to the list
          files.add(XFile(filePath));

          // Share all the downloaded files

          Share.shareXFiles(files, text: text);
        }
      }
    } catch (e) {
      print("Error downloading or sharing files: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String review = "";
    if (business.review != "") {
      review = business.review;
    } else {
      review = "0";
    }
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            SizedBox(
              height: 200,
              child: FutureBuilder<List<Widget>>(
                future: _buildImageWidgets(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading images'));
                  } else {
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: snapshot.data ?? [],
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // // Place Name and Rating
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < int.parse(review)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          );
                        }),
                      ),
                      Text(business.municipal)
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        showSnackbar(context, context.tr("please wait..."));
                        final link =
                            'https://mundotlaxcala.web.app/#/showlinkdetails?${business.toQueryParameters()}';
                        print(link);
                        List<String> imageList =
                            business.imagePaths.cast<String>();
                        if (imageList.isEmpty) {
                          downloadAndShareMultipleImages("", link);
                        } else {
                          String image =
                              business.imagePaths.cast<String>().first;
                         
                          downloadAndShareMultipleImages(image, link);
                        }
                      },
                      icon: const Icon(Icons.share, color: Color(0xFFF95B3D))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // TabBar Section
            TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: [
                Tab(text: context.tr('Overview')),
                Tab(text: context.tr('Promotions')),
                Tab(text: context.tr('Hours')),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildOverviewTab(context),
                  _buildPromotionsTab(context),
                  _buildHoursTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Widget>> _buildImageWidgets(BuildContext context) async {
    List<String> imagePaths = business.imagePaths.cast<String>();
    return imagePaths.map((path) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImagePage(imagePath: path),
                  ),
                );
              },
              child: Image.network(
                path,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            )),
      );
    }).toList();
  }

  Widget _buildOverviewTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildInfoCard(Icons.build, 'service', business.services, context),
        GestureDetector(
            onTap: () {
              launchUrl(Uri.parse(business.locationLink));
            },
            child: _buildInfoCard(Icons.location_on, context.tr('Address'),
                business.address, context)),
        _buildInfoCard(
            Icons.add, context.tr('Added Value'), business.addedValue, context),

        GestureDetector(
          onTap: () {
            launchUrl(Uri.parse(business.website));
          },
          child: _buildInfoCard(
              Icons.language, context.tr(''), business.website, context),
        ),
        GestureDetector(
          onTap: () {
            launchUrl(Uri.parse(business.facebookPage));
          },
          child: _buildInfoCard(
              Icons.facebook, context.tr(''), business.facebookPage, context),
        ),
        GestureDetector(
          onTap: () async {
            final phoneNumber =
                business.phone; // Replace with your phone variable
            final url = 'tel:$phoneNumber';

            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url));
            } else {
              // Handle the error, e.g., show a Snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(context.tr('Could not launch phone call'))),
              );
            }
          },
          child: _buildInfoCard(Icons.phone, '', business.phone, context),
        ),

        // _buildInfoCard(Icons.attach_money, context.tr('Prices'),
        //     business.prices, context),

        // Location Button

        const SizedBox(height: 16),

        // Back Button
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/menu');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF95B3D),
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text(context.tr('Back to Menu'),
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildPromotionsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildInfoCard(
            Icons.sell, context.tr(''), business.promotions, context),
      ],
    );
  }

  Widget _buildHoursTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildInfoCard(
            Icons.calendar_today, context.tr(''), business.eventDate, context),
        _buildInfoCard(Icons.schedule, context.tr(''),
            "${business.openingHours} - ${business.closingHours}", context),
      ],
    );
  }

  Widget _buildInfoCard(
      IconData icon, String title, String content, BuildContext context) {
    if (content.trim() == "") {
      return const SizedBox.shrink();
    }    if (title == "service") {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF270949)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Card(
      color: const Color(0xFFF95B3D),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title == ""
                      ? const SizedBox.shrink()
                      : Text(
                          title,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
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
