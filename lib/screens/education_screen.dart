import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ocuscan_flutter/screens/video_player_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/physician-dashboard'),
        ),
        title: const Text('Education', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          _featuredStory(context),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text('Featured Articles', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 230,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _featuredArticleCard(
                  context,
                  title: 'How to Protect Your Retina in Daily Life',
                  summary: 'Practical tips for screen use, sunlight, and nutrition to keep your retina healthy.',
                  imageUrl: 'https://images.unsplash.com/photo-1465101178521-c1a9136a3c8b?auto=format&fit=crop&w=800&q=80',
                ),
                _featuredArticleCard(
                  context,
                  title: 'Breakthroughs in Retinal Surgery',
                  summary: 'Explore the latest advancements in minimally invasive retinal surgery.',
                  imageUrl: 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=800&q=80',
                ),
                _featuredArticleCard(
                  context,
                  title: 'Nutrition & Eye Health',
                  summary: 'Discover the foods and supplements that support long-term eye health.',
                  imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text('Latest News', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
          ),
          const SizedBox(height: 8),
          _newsCard(
            context,
            title: 'Breakthrough in Retinal Imaging',
            summary: 'Scientists have developed a new imaging technique that allows for earlier detection of retinal diseases.',
            imageUrl: 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80',
            date: 'June 2025',
          ),
          _newsCard(
            context,
            title: 'Smart Glasses Aid the Visually Impaired',
            summary: 'Innovative smart glasses are now helping people with low vision navigate the world more independently.',
            imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
            date: 'June 2025',
          ),
          _newsCard(
            context,
            title: 'AI Revolutionizes Eye Disease Diagnosis',
            summary: 'Artificial Intelligence is now being used to diagnose eye diseases with remarkable accuracy.',
            imageUrl: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=800&q=80',
            date: 'June 2025',
          ),
          _newsCard(
            context,
            title: 'Gene Therapy for Retinal Disorders',
            summary: 'New gene therapies are showing promise for inherited retinal diseases.',
            imageUrl: 'https://images.unsplash.com/photo-1465101178521-c1a9136a3c8b?auto=format&fit=crop&w=800&q=80',
            date: 'May 2025',
          ),
          _newsCard(
            context,
            title: 'Telemedicine Expands Eye Care Access',
            summary: 'Remote consultations are making eye care more accessible to rural communities.',
            imageUrl: 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=800&q=80',
            date: 'May 2025',
          ),
          _newsCard(
            context,
            title: 'Retinal Implants Restore Vision',
            summary: 'Bionic eyes and retinal chips are helping some blind patients regain sight.',
            imageUrl: 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=800&q=80',
            date: 'April 2025',
          ),
          _newsCard(
            context,
            title: 'Eye Health in the Digital Age',
            summary: 'Tips for reducing digital eye strain and protecting your eyes from screens.',
            imageUrl: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?auto=format&fit=crop&w=800&q=80',
            date: 'April 2025',
          ),
          _newsCard(
            context,
            title: 'New Contact Lens Technology',
            summary: 'Discover the latest advancements in contact lens technology for improved eye health.',
            imageUrl: 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=800&q=80',
            date: 'March 2025',
          ),
          _newsCard(
            context,
            title: 'The Importance of Regular Eye Exams',
            summary: 'Learn why regular eye exams are crucial for maintaining good eye health.',
            imageUrl: 'https://images.unsplash.com/photo-1465101178521-c1a9136a3c8b?auto=format&fit=crop&w=800&q=80',
            date: 'March 2025',
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text('Retina Health Tips', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
          ),
          const SizedBox(height: 12),
          _tipsSection(),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text('Eye Health Explained', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
          ),
          const SizedBox(height: 8),
          _newsCard(
            context,
            title: 'Understanding the Retina',
            summary: 'The retina is a thin layer of tissue at the back of the eye that receives light and sends signals to the brain.',
            imageUrl: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?auto=format&fit=crop&w=800&q=80',
            date: 'June 2025',
          ),
          _newsCard(
            context,
            title: 'Types of Glasses and Lenses',
            summary: 'From single vision to progressives, learn which type of glasses is best for your needs.',
            imageUrl: 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=800&q=80',
            date: 'June 2025',
          ),
          _newsCard(
            context,
            title: 'Latest Technology for Eye Care',
            summary: 'Discover the latest advancements in eye care technology, including smart contact lenses and laser treatments.',
            imageUrl: 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=800&q=80',
            date: 'June 2025',
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text('Latest Research', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
          ),
          const SizedBox(height: 12),
          _latestResearchSection(),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text('Latest Videos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _videoCard(context, 'What is the Retina?', 'https://youtu.be/fZDAwXh54is?si=QcCARnP0xCllg_f3'),
                _videoCard(context, 'How Glasses Work', 'https://youtu.be/1vlojCoFrTw?si=sGCyt0k2W5vM40j-'),
                _videoCard(context, 'Future of Eye Tech', 'https://youtu.be/QX8DBTn9vtQ?si=zcPg3hyX0fMvg-uk'),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _featuredStory(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(18),
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=facearea&w=800&h=400&q=80'),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.13),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        Positioned(
          left: 32,
          right: 32,
          bottom: 32,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Featured: Visionary Advances in Eye Health',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 6),
                Text(
                  'Explore how new technology and research are transforming the way we see the world.',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _newsCard(BuildContext context, {required String title, required String summary, required String imageUrl, required String date}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              SizedBox(
                height: 170,
                width: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE3F2FD),
                    child: const Icon(Icons.image, size: 60, color: Color(0xFF1E88E5)),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                        )),
                    const SizedBox(height: 4),
                    Text(summary,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
                        )),
                    const SizedBox(height: 6),
                    Text(date,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFB3E5FC),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _videoCard(BuildContext context, String title, String url) {
    // Extract YouTube video ID for thumbnail
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
        width: 240,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.14),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
              ),
              child: Stack(
                children: [
                  if (thumbnailUrl != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                      child: Image.network(
                        thumbnailUrl,
                        width: double.infinity,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const Center(
                    child: Icon(Icons.play_circle_fill, size: 50, color: Color(0xFF1E88E5)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E88E5))),
            ),
          ],
        ),
      ),
    );
  }

  // --- News Portal Helper Widgets ---
  Widget _featuredArticleCard(BuildContext context, {required String title, required String summary, required String imageUrl}) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.13),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            SizedBox(
              height: 230,
              width: 320,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFE3F2FD),
                  child: const Icon(Icons.image, size: 60, color: Color(0xFF1E88E5)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                      )),
                  const SizedBox(height: 4),
                  Text(summary,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tipRow(Icons.remove_red_eye, 'Take regular screen breaks to reduce eye strain.'),
          _tipRow(Icons.wb_sunny, 'Wear sunglasses to protect your eyes from UV rays.'),
          _tipRow(Icons.local_dining, 'Eat foods rich in vitamin A, C, and E for eye health.'),
          _tipRow(Icons.medical_services, 'Schedule annual eye exams, especially if you have diabetes.'),
          _tipRow(Icons.smoke_free, 'Avoid smoking to lower your risk of retinal diseases.'),
        ],
      ),
    );
  }

  Widget _tipRow(IconData icon, String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E88E5), size: 24),
          const SizedBox(width: 10),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Widget _latestResearchSection() {
    return Column(
      children: [
        _researchCard(
          title: 'Stem Cell Therapy for Macular Degeneration',
          summary: 'Researchers are exploring stem cell implants to restore vision in patients with age-related macular degeneration.',
          source: 'Nature Medicine',
          url: 'https://www.nature.com/articles/s41591-021-01326-8',
        ),
        _researchCard(
          title: 'AI Detects Diabetic Retinopathy',
          summary: 'AI-powered tools are now able to detect diabetic retinopathy from retinal scans with high accuracy.',
          source: 'JAMA Ophthalmology',
          url: 'https://jamanetwork.com/journals/jamaophthalmology/fullarticle/2736588',
        ),
        _researchCard(
          title: 'Blue Light and Retinal Health',
          summary: 'New studies examine the impact of blue light exposure from screens on long-term retinal health.',
          source: 'Ophthalmology Times',
          url: 'https://www.ophthalmologytimes.com/view/blue-light-and-retinal-health',
        ),
      ],
    );
  }

  Widget _researchCard({required String title, required String summary, required String source, required String url}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
              const SizedBox(height: 6),
              Text(summary, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Source: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // ignore: deprecated_member_use
                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      },
                      child: Text(source, style: const TextStyle(fontSize: 13, color: Color(0xFF1E88E5), decoration: TextDecoration.underline)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
