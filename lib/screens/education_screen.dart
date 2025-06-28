import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocuscan_flutter/screens/video_player_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF2563EB);
    final Color surfaceColor = const Color(0xFFFAFAFA);
    final Color cardColor = Colors.white;
    final Color secondaryBlue = const Color(0xFFEFF6FF);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => context.go('/physician-dashboard'),
        ),
        title: const Text(
          'Education',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          _featuredStory(context, primaryBlue, cardColor),
          const SizedBox(height: 32),
          _sectionHeader('Featured Articles', primaryBlue),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _featuredArticleCard(
                  context,
                  title: 'How to Protect Your Retina in Daily Life',
                  summary: 'Practical tips for screen use, sunlight, and nutrition to keep your retina healthy.',
                  imageUrl: 'https://images.unsplash.com/photo-1465101178521-c1a9136a3c8b?auto=format&fit=crop&w=800&q=80',
                  cardColor: cardColor,
                ),
                _featuredArticleCard(
                  context,
                  title: 'Breakthroughs in Retinal Surgery',
                  summary: 'Explore the latest advancements in minimally invasive retinal surgery.',
                  imageUrl: 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=800&q=80',
                  cardColor: cardColor,
                ),
                _featuredArticleCard(
                  context,
                  title: 'Nutrition & Eye Health',
                  summary: 'Discover the foods and supplements that support long-term eye health.',
                  imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
                  cardColor: cardColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _sectionHeader('Latest News', primaryBlue),
          const SizedBox(height: 16),
          _newsCard(
            context,
            title: 'Breakthrough in Retinal Imaging',
            summary: 'Scientists have developed a new imaging technique that allows for earlier detection of retinal diseases.',
            imageUrl: 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80',
            date: 'June 2025',
            cardColor: cardColor,
          ),
          _newsCard(
            context,
            title: 'Smart Glasses Aid the Visually Impaired',
            summary: 'Innovative smart glasses are now helping people with low vision navigate the world more independently.',
            imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
            date: 'June 2025',
            cardColor: cardColor,
          ),
          _newsCard(
            context,
            title: 'AI Revolutionizes Eye Disease Diagnosis',
            summary: 'Artificial Intelligence is now being used to diagnose eye diseases with remarkable accuracy.',
            imageUrl: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=800&q=80',
            date: 'June 2025',
            cardColor: cardColor,
          ),
          _newsCard(
            context,
            title: 'Gene Therapy for Retinal Disorders',
            summary: 'New gene therapies are showing promise for inherited retinal diseases.',
            imageUrl: 'https://images.unsplash.com/photo-1465101178521-c1a9136a3c8b?auto=format&fit=crop&w=800&q=80',
            date: 'May 2025',
            cardColor: cardColor,
          ),
          _newsCard(
            context,
            title: 'Telemedicine Expands Eye Care Access',
            summary: 'Remote consultations are making eye care more accessible to rural communities.',
            imageUrl: 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=800&q=80',
            date: 'May 2025',
            cardColor: cardColor,
          ),
          _newsCard(
            context,
            title: 'Retinal Implants Restore Vision',
            summary: 'Bionic eyes and retinal chips are helping some blind patients regain sight.',
            imageUrl: 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=800&q=80',
            date: 'April 2025',
            cardColor: cardColor,
          ),
          _newsCard(
            context,
            title: 'Eye Health in the Digital Age',
            summary: 'Tips for reducing digital eye strain and protecting your eyes from screens.',
            imageUrl: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?auto=format&fit=crop&w=800&q=80',
            date: 'April 2025',
            cardColor: cardColor,
          ),
          _newsCard(
            context,
            title: 'New Contact Lens Technology',
            summary: 'Discover the latest advancements in contact lens technology for improved eye health.',
            imageUrl: 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=800&q=80',
            date: 'March 2025',
            cardColor: cardColor,
          ),
          _newsCard(
            context,
            title: 'The Importance of Regular Eye Exams',
            summary: 'Learn why regular eye exams are crucial for maintaining good eye health.',
            imageUrl: 'https://images.unsplash.com/photo-1465101178521-c1a9136a3c8b?auto=format&fit=crop&w=800&q=80',
            date: 'March 2025',
            cardColor: cardColor,
          ),
          const SizedBox(height: 40),
          _sectionHeader('Retina Health Tips', primaryBlue),
          const SizedBox(height: 16),
          _tipsSection(primaryBlue, cardColor, secondaryBlue),
          const SizedBox(height: 40),
          _sectionHeader('Eye Health Explained', primaryBlue),
          const SizedBox(height: 16),
          _newsCard(
            context,
            title: 'Understanding the Retina',
            summary: 'The retina is a thin layer of tissue at the back of the eye that receives light and sends signals to the brain.',
            imageUrl: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?auto=format&fit=crop&w=800&q=80',
            date: 'June 2025',
            cardColor: cardColor,
          ),
          _newsCard(
            context,
            title: 'Types of Glasses and Lenses',
            summary: 'From single vision to progressives, learn which type of glasses is best for your needs.',
            imageUrl: 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=800&q=80',
            date: 'June 2025',
            cardColor: cardColor,
          ),
          _newsCard(
            context,
            title: 'Latest Technology for Eye Care',
            summary: 'Discover the latest advancements in eye care technology, including smart contact lenses and laser treatments.',
            imageUrl: 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=800&q=80',
            date: 'June 2025',
            cardColor: cardColor,
          ),
          const SizedBox(height: 40),
          _sectionHeader('Latest Research', primaryBlue),
          const SizedBox(height: 16),
          _latestResearchSection(cardColor, primaryBlue),
          const SizedBox(height: 40),
          _sectionHeader('Latest Videos', primaryBlue),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _videoCard(context, 'What is the Retina?', 'https://youtu.be/fZDAwXh54is?si=QcCARnP0xCllg_f3', cardColor, primaryBlue),
                _videoCard(context, 'How Glasses Work', 'https://youtu.be/1vlojCoFrTw?si=sGCyt0k2W5vM40j-', cardColor, primaryBlue),
                _videoCard(context, 'Future of Eye Tech', 'https://youtu.be/QX8DBTn9vtQ?si=zcPg3hyX0fMvg-uk', cardColor, primaryBlue),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, Color primaryBlue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: primaryBlue,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _featuredStory(BuildContext context, Color primaryBlue, Color cardColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 240,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&h=400&q=80'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Visionary Advances in Eye Health',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explore how new technology and research are transforming the way we see the world.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newsCard(BuildContext context, {
    required String title,
    required String summary,
    required String imageUrl,
    required String date,
    required Color cardColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFEFF6FF),
                  child: const Icon(Icons.image_outlined, size: 60, color: Color(0xFF2563EB)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _videoCard(BuildContext context, String title, String url, Color cardColor, Color primaryBlue) {
    String? videoId;
    final uri = Uri.tryParse(url);
    if (uri != null) {
      if (uri.host.contains('youtu.be')) {
        videoId = uri.pathSegments.first;
      } else if (uri.host.contains('youtube.com')) {
        videoId = uri.queryParameters['v'];
      }
    }
    final thumbnailUrl = videoId != null
        ? 'https://img.youtube.com/vi/$videoId/0.jpg'
        : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(videoUrl: url, title: title),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 130,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                ),
                child: Stack(
                  children: [
                    if (thumbnailUrl != null)
                      Image.network(
                        thumbnailUrl,
                        width: double.infinity,
                        height: 130,
                        fit: BoxFit.cover,
                      ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featuredArticleCard(BuildContext context, {
    required String title,
    required String summary,
    required String imageUrl,
    required Color cardColor,
  }) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160,
                width: 320,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFEFF6FF),
                    child: const Icon(Icons.image_outlined, size: 60, color: Color(0xFF2563EB)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipsSection(Color primaryBlue, Color cardColor, Color secondaryBlue) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tipRow(Icons.visibility_outlined, 'Take regular screen breaks to reduce eye strain.', primaryBlue, secondaryBlue),
          _tipRow(Icons.wb_sunny_outlined, 'Wear sunglasses to protect your eyes from UV rays.', primaryBlue, secondaryBlue),
          _tipRow(Icons.restaurant_outlined, 'Eat foods rich in vitamin A, C, and E for eye health.', primaryBlue, secondaryBlue),
          _tipRow(Icons.medical_services_outlined, 'Schedule annual eye exams, especially if you have diabetes.', primaryBlue, secondaryBlue),
          _tipRow(Icons.smoke_free_outlined, 'Avoid smoking to lower your risk of retinal diseases.', primaryBlue, secondaryBlue),
        ],
      ),
    );
  }

  Widget _tipRow(IconData icon, String tip, Color primaryBlue, Color secondaryBlue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: secondaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _latestResearchSection(Color cardColor, Color primaryBlue) {
    return Column(
      children: [
        _researchCard(
          title: 'Stem Cell Therapy for Macular Degeneration',
          summary: 'Researchers are exploring stem cell implants to restore vision in patients with age-related macular degeneration.',
          source: 'Nature Medicine',
          url: 'https://www.nature.com/articles/s41591-021-01326-8',
          cardColor: cardColor,
          primaryBlue: primaryBlue,
        ),
        _researchCard(
          title: 'AI Detects Diabetic Retinopathy',
          summary: 'AI-powered tools are now able to detect diabetic retinopathy from retinal scans with high accuracy.',
          source: 'JAMA Ophthalmology',
          url: 'https://jamanetwork.com/journals/jamaophthalmology/fullarticle/2736588',
          cardColor: cardColor,
          primaryBlue: primaryBlue,
        ),
        _researchCard(
          title: 'Blue Light and Retinal Health',
          summary: 'New studies examine the impact of blue light exposure from screens on long-term retinal health.',
          source: 'Ophthalmology Times',
          url: 'https://www.ophthalmologytimes.com/view/blue-light-and-retinal-health',
          cardColor: cardColor,
          primaryBlue: primaryBlue,
        ),
      ],
    );
  }

  Widget _researchCard({
    required String title,
    required String summary,
    required String source,
    required String url,
    required Color cardColor,
    required Color primaryBlue,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryBlue,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.link, size: 16, color: primaryBlue),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  },
                  child: Text(
                    source,
                    style: TextStyle(
                      fontSize: 14,
                      color: primaryBlue,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}