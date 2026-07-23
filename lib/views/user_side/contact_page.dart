import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/contact_model.dart';
import 'sections/user_header.dart';
import 'sections/user_footer.dart';
import '../../utils/app_typography.dart';

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
  String _messageCountText = '';
  String? _errorText;
  int activeTab = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  List<String> get tabTitles => [AppLocalizations.of(context)?.enquiries ?? 'ENQUIRIES'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMessageCount();
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
    if (AppLocalizations.of(context) == null) return;
    final count = _messageController.text.length;
    setState(() {
      _messageCountText = AppLocalizations.of(context)!.countCharacters(count);
    });
  }

  Future<void> _submitForm(HomePageController controller) async {
    if (!_formKey.currentState!.validate()) return;
    if (!_robotChecked) {
      setState(() {
        _errorText = AppLocalizations.of(context)!.verifyNotRobot;
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
        SnackBar(content: Text(AppLocalizations.of(context)!.messageSavedEmailOpened)),
      );
      _clearForm();
      setState(() {
        _robotChecked = false;
        _isSubmitting = false;
      });
    }
  }

  Future<void> _launchEmailClient(ContactInquiry inquiry) async {
    final subject = Uri.encodeComponent(AppLocalizations.of(context)!.websiteContactFormMessage);
    final body = Uri.encodeComponent(
      'Name: ${inquiry.name}\n'
      'Email: ${inquiry.email}\n'
      'Tel/Mobile: ${inquiry.mobile}\n'
      'Country: ${inquiry.country}\n'
      'Type: ${inquiry.type}\n\n'
      'Message:\n${inquiry.message}',
    );
    final uri = Uri.parse(
      'mailto:$_recipientEmail?subject=$subject&body=$body',
    );
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
      _messageCountText = AppLocalizations.of(context)!.countCharacters(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    final controller = Provider.of<HomePageController>(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

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
              AppLocalizations.of(context)!.contactUs,
              style: AppTypography.headingStyle(
                context,
                fontSize: AppTypography.getResponsiveSize(context, desktop: 52, tablet: 44, mobile: 34),
                fontWeight: FontWeight.bold,
                color: primaryTeal,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${AppLocalizations.of(context)!.home} > ${AppLocalizations.of(context)!.contactUs}',
              style: TextStyle(
                color: primaryTeal.withOpacity(0.6),
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 60),

            // Navigation - Only Enquiries
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.enquiries,
                      style: const TextStyle(
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

            SizedBox(height: isMobile ? 30 : 60),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 100),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.siteQueryDisclaimer,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: isMobile ? 14 : 16),
                  ),
                  SizedBox(height: isMobile ? 30 : 60),
                  _buildForm(controller, primaryTeal, isMobile),
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

  Widget _buildForm(HomePageController controller, Color primaryTeal, bool isMobile) {
    return Form(
      key: _formKey,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        padding: EdgeInsets.all(isMobile ? 20 : 50),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 40,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobile) ...[
              _formField(AppLocalizations.of(context)!.nameLabel, _nameController, primaryTeal),
              const SizedBox(height: 20),
              _formField(AppLocalizations.of(context)!.emailLabel, _emailController, primaryTeal),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _formField(AppLocalizations.of(context)!.nameLabel, _nameController, primaryTeal),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: _formField(
                      AppLocalizations.of(context)!.emailLabel,
                      _emailController,
                      primaryTeal,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: isMobile ? 20 : 40),
            if (isMobile) ...[
              _formField(AppLocalizations.of(context)!.telMobileLabel, _mobileController, primaryTeal),
              const SizedBox(height: 20),
              _formField(AppLocalizations.of(context)!.countryLabel, _countryController, primaryTeal),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _formField(
                      AppLocalizations.of(context)!.telMobileLabel,
                      _mobileController,
                      primaryTeal,
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: _formField(
                      AppLocalizations.of(context)!.countryLabel,
                      _countryController,
                      primaryTeal,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 40),
            _formField(
              AppLocalizations.of(context)!.messageLabel,
              _messageController,
              primaryTeal,
              maxLines: 6,
            ),
            const SizedBox(height: 12),
            Text(
              _messageCountText,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
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
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.imNotRobot,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Icon(Icons.refresh, color: Colors.blue, size: 24),
                ],
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 15),
              Text(
                _errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],

            const SizedBox(height: 50),

            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submitForm(controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isSubmitting ? AppLocalizations.of(context)!.sending : AppLocalizations.of(context)!.sendMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField(
    String label,
    TextEditingController controller,
    Color primaryTeal, {
    int maxLines = 1,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF444444),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 16),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return AppLocalizations.of(context)!.requiredField;
            if (label.contains('Email') &&
                !RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(value.trim()))
              return AppLocalizations.of(context)!.invalidEmail;
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
