import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tlaxcala_world/business_model.dart';
import 'package:tlaxcala_world/full_screen_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class DetailsScreen extends StatefulWidget {
  final Business business;

  const DetailsScreen({super.key, required this.business});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
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
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF270949)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Color(0xFF270949)),
              onPressed: () => _shareBusiness(widget.business),
            ),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
_buildImageGallery(context, widget.business),
                      _buildHeaderSection(context),
                      _buildRatingSection(context),

                      _buildContactBar(context),
                      const SizedBox(height: 24),
                      //_buildSectionTitle(context.tr('About')),
                      _buildServiceChips(widget.business, context),
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
                      Tab(text: context.tr('Promotions')),
                      // Tab(text: context.tr('Hours')),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  children: [
                    _buildDetailsTab(context, widget.business),
                    _buildPromotionsTab(context, widget.business),
                    // _buildHoursTab(context, widget.business),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _launchMap(context, widget.business.locationLink),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.location_pin, color: Colors.white),
        ),
      ),
    );
  }

  /////

  int _currentImageIndex = 0;

   Widget _buildImageGallery(BuildContext context, Business business) {
    return SizedBox(
      height: MediaQuery.of(context).size.width * 9 / 16, // 16:9 aspect ratio
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // PageView for swiping between images
          PageView.builder(
            itemCount: business.imagePaths.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
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
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.blue.shade800,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: Colors.red, size: 40),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          // Image count indicator
          Positioned(
            bottom: 16.0,
            left: 5.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image, color: Colors.white, size: 16.0),
                  const SizedBox(width: 6.0),
                  Text(
                    '${_currentImageIndex + 1}/${business.imagePaths.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ),
          // Pagination dots (only if multiple images)
          if (business.imagePaths.length > 1)
            Positioned(
              left:5.0,
              bottom: 2.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(business.imagePaths.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: _currentImageIndex == index ? 12.0 : 8.0,
                    height: _currentImageIndex == index ? 12.0 : 8.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.blue.shade800
                          : Colors.white.withOpacity(0.8),
                      border: Border.all(color: Colors.blue.shade800, width: 1.0),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.business.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
        ),
        Text(
          widget.business.municipal,
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
                      index < int.parse(widget.business.review)
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 28,
                    )),
          ),
          const SizedBox(width: 8),
          Text(
            '(${widget.business.review})',
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         widget.business.website==""?const SizedBox.shrink():GestureDetector(
          onTap: () {
            _launchWebsite(context, widget.business.website);
          },
          child: Text(
            style: const TextStyle(
              decoration: TextDecoration.underline,
            ),
            context.tr("Visit website"),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        widget.business.facebookPage==""?const SizedBox.shrink():
        GestureDetector(
          onTap: () {
            _launchFacebook(context, widget.business.facebookPage);
          },
          child: Text(
            style: const TextStyle(
              decoration: TextDecoration.underline,
            ),
            context.tr("Visit Facebook page"),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        widget.business.openingHours==""||widget.business.closingHours==""?const SizedBox.shrink():Text(
          "${context.tr("Open from")}: ${widget.business.openingHours} ${context.tr("to")} ${widget.business.closingHours}",
          style: const TextStyle(),
        ),
        // _buildContactButton(
        //   icon: Icons.phone,
        //   label: "",
        //   onPressed: () => _launchPhone(context, widget.business.phone),
        // ),
        // _buildContactButton(
        //   icon: Icons.language,
        //   label: "",
        //   onPressed: () => _launchWebsite(context, widget.business.website),
        // ),
        // _buildContactButton(
        //   icon: Icons.facebook,
        //   label: "",
        //   onPressed: () => _launchFacebook(context, widget.business.facebookPage),
        // ),
      ],
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
    print(websiteUri);
    
      await launchUrl(websiteUri);
    
  }

  /// Launches the Facebook page specified by [url].
  Future<void> _launchFacebook(BuildContext context, String url) async {
    final Uri facebookUri = Uri.parse(url);
   await launchUrl(facebookUri);
   
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

Widget _buildServiceChips(Business business, BuildContext context) {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr("About"),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ), Text(
              business.services,
              maxLines:
                  100, // Change to 1 if you want a single line with ellipsis.
              // overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
        ],
      ),
    ],
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
  if (content.trim() == "") {
    return const SizedBox.shrink();
  }
  
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      bool isExpanded = false;
      final textSpan = TextSpan(
        text: content,
        style: const TextStyle(color: Colors.black), // Default ListTile title color
      );
      
      final textPainter = TextPainter(
        text: textSpan,
        maxLines: 3,
      )..layout(maxWidth: MediaQuery.of(context).size.width - 100); // Adjust for padding and icon

      final isOverflowing = textPainter.didExceedMaxLines;

      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFF95B3D)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: const TextStyle(color: Colors.black),
              maxLines: isExpanded ? null : 3,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
              textAlign: content.length > 100 ? TextAlign.justify : TextAlign.left,
            ),
            if (isOverflowing && !isExpanded)
              GestureDetector(
                onTap: () => setState(() => isExpanded = true),
                child:  Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                   '${context.tr('Read More')}...',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (isOverflowing && isExpanded)
              GestureDetector(
                onTap: () => setState(() => isExpanded = false),
                child:  Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    context.tr('Show Less'),
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      );
    },
  );
}

Widget _buildPromotionsTab(BuildContext context, Business business) {
  return ListView(
    padding: const EdgeInsets.all(16.0),
    children: [
      _buildInfoCard(Icons.sell, "", business.promotions, context),
    ],
  );
}

Widget _buildHoursTab(BuildContext context, Business business) {
  return ListView(
    padding: const EdgeInsets.all(16.0),
    children: [
      _buildInfoCard(Icons.calendar_today, "", business.eventDate, context),
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
                      const TextStyle(fontSize: 14, ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  return Card(
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
                            fontWeight: FontWeight.bold,),
                      ),
                const SizedBox(height: 4),
                _buildContentText(content),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildContentText(String content) {
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      bool isExpanded = false;
      final textSpan = TextSpan(
        text: content,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      );
      
      final textPainter = TextPainter(
        text: textSpan,
        maxLines: 3,
      )..layout(maxWidth: MediaQuery.of(context).size.width - 80); // Adjust width based on padding and icon

      final isOverflowing = textPainter.didExceedMaxLines;

      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: const TextStyle(fontSize: 14, color: Colors.white),
                maxLines: isExpanded ? null : 3,
                overflow: isExpanded ? null : TextOverflow.ellipsis,
                textAlign: content.length > 100 ? TextAlign.justify : TextAlign.left,
              ),
              if (isOverflowing && !isExpanded)
                GestureDetector(
                  onTap: () => setState(() => isExpanded = true),
                  child:  Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${context.tr('Read More')}...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (isOverflowing && isExpanded)
                GestureDetector(
                  onTap: () => setState(() => isExpanded = false),
                  child:  Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Text(
                      context.tr('Show Less'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    },
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
