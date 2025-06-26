import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() {
      _submitting = true;
    });
    // Simulate sending feedback
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _submitting = false;
      _feedbackController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback sent!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
           onPressed: () => context.go('/settings'),
        ),
        title: const Text('Support', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.help_outline, size: 22, color: Color(0xFF1E88E5)),
                        SizedBox(width: 8),
                        Text(
                          "We're here to help!",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "If you have any questions, feedback, or need assistance, please let us know and we'll get back to you as soon as possible.",
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    const SizedBox(height: 24),
                    // FAQ Section
                    Row(
                      children: const [
                        Icon(Icons.chat_bubble_outline, size: 20, color: Color(0xFF1E88E5)),
                        SizedBox(width: 6),
                        Text(
                          'Frequently Asked Questions',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFaqItem(
                      question: 'How do I reset my password?',
                      answer: "Go to Account Settings, tap on 'Change Password', and follow the instructions to reset your password securely.",
                    ),
                    _buildFaqItem(
                      question: 'Is my data safe?',
                      answer: 'Yes. All patient data and images are encrypted and handled with strict confidentiality according to medical data regulations.',
                    ),
                    _buildFaqItem(
                      question: 'How do I contact support?',
                      answer: "Use the feedback form below or email us at ",
                      email: 'support@ocuscan.com',
                    ),
                    const SizedBox(height: 28),
                    // Feedback Form
                    const Text(
                      'Your Feedback',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _feedbackController,
                      minLines: 6,
                      maxLines: 8,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: 'Type your message here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _submitting ? Colors.grey[300] : const Color(0xFF1E88E5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _submitting ? null : _handleSubmit,
                        child: Text(
                          _submitting ? 'Sending...' : 'Send Feedback',
                          style: TextStyle(
                            color: _submitting ? Colors.black54 : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer, String? email}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    children: [
                      TextSpan(text: answer),
                      if (email != null) ...[
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: email,
                          style: const TextStyle(color: Color(0xFF1E88E5)),
                        ),
                        const TextSpan(text: ". We'll respond as soon as possible."),
                      ],
                    ],
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
