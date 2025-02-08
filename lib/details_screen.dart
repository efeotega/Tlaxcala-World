import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tlaxcala_world/business_model.dart';
import 'package:tlaxcala_world/full_screen_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class DetailsScreen extends StatelessWidget {
  final Business business;

  const DetailsScreen({super.key, required this.business});

  Future<void> downloadAndShareMultipleImages(String text) async {
    try {
      Share.share(text);
    } catch (e) {
      print("Error downloading or sharing files: $e");
    }
  }

  void _shareBusiness(Business business) {
    final link =
        'https://mundotlaxcala.web.app/#/showlinkdetails?${business.toQueryParameters()}';
    downloadAndShareMultipleImages(link);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              
              expandedHeight: 210,
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.share, color: Color(0xFF270949)),
                  onPressed: () => _shareBusiness(business),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode
                    .parallax, // Use parallax to reduce scaling issues
                background: _buildImageGallery(context, business),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(context),
                    _buildRatingSection(context),
                    _buildContactBar(context),
                    const SizedBox(height: 24),
                    //_buildSectionTitle(context.tr('About')),
                    _buildServiceChips(business),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  tabs: [
                    Tab(text: context.tr('Details')),
                    Tab(text: context.tr('Offers')),
                    Tab(text: context.tr('Hours')),
                  ],
                ),
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                children: [
                  _buildDetailsTab(context, business),
                  _buildPromotionsTab(context, business),
                  _buildHoursTab(context, business),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _launchMap(context, business.locationLink),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.location_pin, color: Colors.white),
        ),
      ),
    );
  }
  /////


Widget _buildImageGallery(BuildContext context, Business business) {
  final imageCount = business.imagePaths.length;

  // For a few images, use a Row with dynamic width for each image.
  if (imageCount <= 5) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available width, subtracting some margin space.
        const horizontalPadding = 5.0; // total margin per image (adjust as needed)
        // final tileWidth =
        //     (constraints.maxWidth - ((imageCount + 1) * horizontalPadding)) /
        //         imageCount;
                final tileWidth=MediaQuery.of(context).size.width/imageCount;
                final tileWidthh=tileWidth*0.9;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              children: business.imagePaths.map((imageUrl) {
                return Container(
                  width: tileWidthh,
                  margin: const EdgeInsets.all(5.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FullScreenImagePage(imagePath: imageUrl),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 150,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // For many images, use the MasonryGridView as before.
  return MasonryGridView.count(
    padding: const EdgeInsets.all(5.0),
    // Keep 2 rows for horizontal scrolling.
    crossAxisCount: 2,
    scrollDirection: Axis.horizontal,
    mainAxisSpacing: 3,
    crossAxisSpacing: 2,
    itemCount: business.imagePaths.length,
    itemBuilder: (context, index) {
      final imageUrl = business.imagePaths[index];
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenImagePage(imagePath: imageUrl),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 150, // Temporary height for loading state
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
      );
    },
  );
}


  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          business.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
        ),
        Text(
          business.municipal,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Wrap(
            spacing: 4,
            children: List.generate(
                5,
                (index) => Icon(
                      index < int.parse(business.review)
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 28,
                    )),
          ),
          const SizedBox(width: 8),
          Text(
            '(${business.review})',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200] ?? Colors.grey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildContactButton(
            icon: Icons.phone,
            label: "",
            onPressed: () => _launchPhone(context, business.phone),
          ),
          _buildContactButton(
            icon: Icons.language,
            label: "",
            onPressed: () => _launchWebsite(context, business.website),
          ),
          _buildContactButton(
            icon: Icons.facebook,
            label: "",
            onPressed: () => _launchFacebook(context, business.facebookPage),
          ),
        ],
      ),
    );
  }

  /// Helper widget to build a contact button with an icon and label.
  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 28, color: const Color(0xFF270949)),
          onPressed: onPressed,
        ),
        //Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  /// Launches the phone dialer with the provided [phoneNumber].
  Future<void> _launchPhone(BuildContext context, String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone app')),
      );
    }
  }

  /// Launches the website specified by [url].
  Future<void> _launchWebsite(BuildContext context, String url) async {
    final Uri websiteUri = Uri.parse(url);
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch website')),
      );
    }
  }

  /// Launches the Facebook page specified by [url].
  Future<void> _launchFacebook(BuildContext context, String url) async {
    final Uri facebookUri = Uri.parse(url);
    if (await canLaunchUrl(facebookUri)) {
      await launchUrl(facebookUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch Facebook')),
      );
    }
  }
}

Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    ),
  );
}

Widget _buildServiceChips(Business business) {
  return Wrap(
    spacing:8,
    runSpacing:8,
    children:[
      Chip(
        label:Text(business.services),
        backgroundColor:Colors.blue[50],
        labelStyle:const TextStyle(color:Color(0xFFF95B3D)),
         shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      )
    ]
  );
}

void _launchMap(BuildContext context, String locationLink) {
  launchUrl(Uri.parse(locationLink));
}

Widget _buildDetailsTab(BuildContext context, Business business) {
  return ListView(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    children: [
      _buildInfoItem(
        icon: Icons.assistant_direction,
        title: "",
        content: business.address,
        onTap: () => _launchMap(context, business.locationLink),
      ),
      _buildInfoItem(
        icon: Icons.attach_money,
        title: "",
        content: business.prices,
      ),
      _buildInfoItem(
        icon: Icons.event_available,
        title: "",
        content: business.eventDate,
      ),
      _buildInfoItem(
        icon: Icons.lock_open,
        title: "",
        content: business.openingHours,
      ),
      _buildInfoItem(
        icon: Icons.lock,
        title: "",
        content: business.closingHours,
      ),
      _buildInfoItem(
        icon: Icons.add_business,
        title: context.tr('Added Value'),
        content: business.addedValue,
      ),
    ],
  );
}

Widget _buildInfoItem({
  required IconData icon,
  required String title,
  required String content,
  VoidCallback? onTap,
}) {
  if(content.trim()==""){
    return const SizedBox.shrink();
  }
  return ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: const Color(0xFFF95B3D)),
    ),
    // title: Text(title,
    //     style: TextStyle(
    //       fontWeight: FontWeight.w500,
    //       color: Colors.grey[800],
    //     )),
    title: Text(content),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(vertical: 8),
  );
}

Widget _buildPromotionsTab(BuildContext context, Business business) {
  return ListView(
    padding: const EdgeInsets.all(16.0),
    children: [
      _buildInfoCard(Icons.sell,"", business.promotions, context),
    ],
  );
}

Widget _buildHoursTab(BuildContext context, Business business) {
  return ListView(
    padding: const EdgeInsets.all(16.0),
    children: [
      _buildInfoCard(
          Icons.calendar_today, "", business.eventDate, context),
      _buildInfoCard(Icons.schedule, "",
          "${business.openingHours} - ${business.closingHours}", context),
    ],
  );
}

Widget _buildInfoCard(
    IconData icon, String title, String content, BuildContext context) {
  if (content.trim() == "") {
    return const SizedBox.shrink();
  }
  if (title == "Go To Facebook Page") {
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
                          context.tr(title),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  if (title == "service") {
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
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF270949)),
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
                        context.tr(title),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                const SizedBox(height: 4),
                Text(content,
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

// Sticky TabBar Delegate
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: tabBar,
      );

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) => false;
}
