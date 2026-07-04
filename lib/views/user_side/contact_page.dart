import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/contact_model.dart';
import 'sections/user_header.dart';
import 'sections/user_footer.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  static const String _recipientEmail = 'contact@example.com';
  final _formKey = GlobalKey<FormState>();
  bool _robotChecked = false;
  bool _isSubmitting = false;
  String _messageCountText = '0 of 500 max characters.';
  String? _errorText;
  int activeTab = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final List<String> tabTitles = [
    'Enquiries',
  ];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_updateMessageCount);
  }

  @override
  void dispose() {
    _messageController.removeListener(_updateMessageCount);
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _countryController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _updateMessageCount() {
    final count = _messageController.text.length;
    setState(() {
      _messageCountText = '$count of 500 max characters.';
    });
  }

  Future<void> _submitForm(HomePageController controller) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_robotChecked) {
      setState(() {
        _errorText = 'Please verify that you are not a robot.';
      });
      return;
    }

    setState(() {
      _errorText = null;
      _isSubmitting = true;
    });

    final inquiry = ContactInquiry(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim(),
      country: _countryController.text.trim(),
      message: _messageController.text.trim(),
      type: tabTitles[activeTab],
    );

    await controller.submitInquiry(inquiry);
    await _launchEmailClient(inquiry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message saved and email draft opened.')),
      );
      _clearForm();
      setState(() {
        _robotChecked = false;
        _isSubmitting = false;
      });
    }
  }

  Future<void> _launchEmailClient(ContactInquiry inquiry) async {
    final subject = Uri.encodeComponent('Website Contact Form Message');
    final body = Uri.encodeComponent(
      'Name: ${inquiry.name}\n'
      'Email: ${inquiry.email}\n'
      'Tel/Mobile: ${inquiry.mobile}\n'
      'Country: ${inquiry.country}\n'
      'Type: ${inquiry.type}\n\n'
      'Message:\n${inquiry.message}',
    );
    final uri = Uri.parse('mailto:$_recipientEmail?subject=$subject&body=$body');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _mobileController.clear();
    _countryController.clear();
    _messageController.clear();
    setState(() {
      _messageCountText = '0 of 500 max characters.';
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    final controller = Provider.of<HomePageController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserHeader(controller: controller),
            
            // NEW: Contact Page Banner Image
            if (controller.contactPageData.bannerImageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Image.network(
                  controller.contactPageData.bannerImageUrl,
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const SizedBox.shrink(),
                ),
              ),

            const SizedBox(height: 40),
            Text(
              'Contact Us',
              style: TextStyle(fontSize: 52, fontFamily: 'serif', color: primaryTeal, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Home > Contact Us', style: TextStyle(color: primaryTeal.withOpacity(0.6), fontSize: 16, letterSpacing: 0.5)),

            const SizedBox(height: 60),

            // Navigation - Only Enquiries
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text(
                      'ENQUIRIES',
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: primaryTeal,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(height: 4, width: 60, color: primaryTeal),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 60),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Column(
                children: [
                  const Text(
                    'This site is an informative website, therefore please fill in the form below for any technical website related queries only.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 60),
                  _buildForm(controller, primaryTeal),
                ],
              ),
            ),

            const SizedBox(height: 120),
            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(HomePageController controller, Color primaryTeal) {
    return Form(
      key: _formKey,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        padding: const EdgeInsets.all(50),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 40, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _formField('Name *', _nameController, primaryTeal)),
                const SizedBox(width: 40),
                Expanded(child: _formField('Email address *', _emailController, primaryTeal)),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(child: _formField('Tel/Mobile# *', _mobileController, primaryTeal, prefix: '🇮🇳 +91')),
                const SizedBox(width: 40),
                Expanded(child: _formField('Country *', _countryController, primaryTeal)),
              ],
            ),
            const SizedBox(height: 40),
            _formField('Message *', _messageController, primaryTeal, maxLines: 6),
            const SizedBox(height: 12),
            Text(_messageCountText, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 40),
            
            // Robot Verification
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFFBFBFB),
              ),
              child: Row(
                children: [
                  Checkbox(
                    activeColor: primaryTeal,
                    value: _robotChecked,
                    onChanged: (value) => setState(() {
                      _robotChecked = value ?? false;
                      _errorText = null;
                    }),
                  ),
                  const Expanded(child: Text('I\'m not a robot', style: TextStyle(fontSize: 16))),
                  const SizedBox(width: 15),
                  const Icon(Icons.refresh, color: Colors.blue, size: 24),
                ],
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 15),
              Text(_errorText!, style: const TextStyle(color: Colors.red, fontSize: 14)),
            ],
            
            const SizedBox(height: 50),
            
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitForm(controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  _isSubmitting ? 'SENDING...' : 'SEND MESSAGE',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField(String label, TextEditingController controller, Color primaryTeal, {int maxLines = 1, String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF444444), letterSpacing: 0.5)),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 16),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Required';
            if (label.contains('Email') && !RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(value.trim())) return 'Invalid email';
            return null;
          },
          decoration: InputDecoration(
            prefixText: prefix != null ? '$prefix ' : null,
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            contentPadding: const EdgeInsets.all(20),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryTeal, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
