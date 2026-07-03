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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

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
      type: 'Enquiries',
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
    final controller = Provider.of<HomePageController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserHeader(controller: controller),
            const SizedBox(height: 60),
            const Text(
              'Contact us',
              style: TextStyle(fontSize: 48, fontFamily: 'serif', color: Color(0xFF444444)),
            ),
            const SizedBox(height: 8),
            const Text('Home > Contact us', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 60),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Column(
                children: [
                  const Text(
                    'This site is an informative website, therefore please fill in the form below for any technical website related queries only.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  _buildForm(controller),
                ],
              ),
            ),

            const SizedBox(height: 100),
            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(HomePageController controller) {
    return Form(
      key: _formKey,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 820),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE9E9E9)),
          boxShadow: [
            const BoxShadow(color: Color.fromRGBO(158, 158, 158, 0.05), blurRadius: 18, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _formField('Name *', _nameController)),
                const SizedBox(width: 20),
                Expanded(child: _formField('Email address *', _emailController)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _formField('Tel/Mobile# *', _mobileController, prefix: '🇮🇳 +91')),
                const SizedBox(width: 20),
                Expanded(child: _formField('Country *', _countryController)),
              ],
            ),
            const SizedBox(height: 20),
            _formField('Message *', _messageController, maxLines: 6),
            const SizedBox(height: 8),
            Text(_messageCountText, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFFF8F8F8),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _robotChecked,
                    onChanged: (value) => setState(() {
                      _robotChecked = value ?? false;
                      _errorText = null;
                    }),
                  ),
                  const Expanded(child: Text('I\'m not a robot', style: TextStyle(fontSize: 14))),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.refresh, color: Colors.blue, size: 20),
                  ),
                ],
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(_errorText!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitForm(controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC19A6B),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(
                  _isSubmitting ? 'Sending...' : 'Send',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField(String label, TextEditingController controller, {int maxLines = 1, String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: label == 'Message *' ? 500 : null,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Required';
            }
            if (label == 'Email address *' && !RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(value.trim())) {
              return 'Enter a valid email';
            }
            return null;
          },
          decoration: InputDecoration(
            counterText: '',
            prefixText: prefix != null ? '$prefix ' : null,
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
