import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  const VideoPlayerScreen({Key? key, required this.videoUrl, required this.title}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _controller;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = _extractVideoId(widget.videoUrl);
    if (_videoId != null && _videoId!.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: _videoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String? _extractVideoId(String url) {
    // Remove any trailing parameters
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    } else if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['v'];
    }
    // Fallback to package method
    return YoutubePlayer.convertUrlToId(url);
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: const Color(0xFF1E88E5),
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (_controller != null && _controller!.value.isFullScreen) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please exit full-screen mode before going back.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                // Add a small delay to allow the player to clean up
                await Future.delayed(const Duration(milliseconds: 200));
                if (mounted) Navigator.of(context).pop();
              },
            ),
            title: Text(widget.title),
            backgroundColor: const Color(0xFF1E88E5),
          ),
          body: _videoId == null || _videoId!.isEmpty
              ? Center(
                  child: Text(
                    'Could not load video. Invalid YouTube URL.',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      player,
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Text('Eye & Retina Education', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                      ),
                      const SizedBox(height: 12),
                      _eduCard(
                        title: 'Understanding the Eye',
                        icon: Icons.remove_red_eye,
                        content: 'The human eye is a complex organ that allows us to see the world. It focuses light onto the retina, which sends signals to the brain.'
                      ),
                      _eduCard(
                        title: 'What is the Retina?',
                        icon: Icons.visibility,
                        content: 'The retina is a thin layer of tissue at the back of the eye responsible for converting light into neural signals.'
                      ),
                      _eduCard(
                        title: 'Common Retina Diseases',
                        icon: Icons.science,
                        content: 'Diseases like diabetic retinopathy, macular degeneration, and retinal detachment can impact vision and require prompt treatment.'
                      ),
                      _eduCard(
                        title: 'Prevention & Eye Care',
                        icon: Icons.health_and_safety,
                        content: 'Regular eye exams, a healthy diet, UV protection, and managing chronic conditions help protect your eyes and retina.'
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _eduCard({required String title, required IconData icon, required String content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: const Color(0xFF1E88E5)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                    const SizedBox(height: 6),
                    Text(content, style: const TextStyle(fontSize: 14, color: Color(0xFF222222))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
