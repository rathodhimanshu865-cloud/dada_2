import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import '../../controllers/homepage_controller.dart';
import '../../models/contact_model.dart';
import 'sections/user_page_layout.dart';
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
  bool _isSent = false;
  String _messageCountText = '';
  String? _errorText;
  int activeTab = 0;
  bool _isVisible = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final Map<String, GlobalKey<_ShakeableFormFieldState>> _fieldKeys = {
    'name': GlobalKey<_ShakeableFormFieldState>(),
    'email': GlobalKey<_ShakeableFormFieldState>(),
    'mobile': GlobalKey<_ShakeableFormFieldState>(),
    'country': GlobalKey<_ShakeableFormFieldState>(),
    'message': GlobalKey<_ShakeableFormFieldState>(),
  };

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
    bool isValid = _formKey.currentState!.validate();
    if (!isValid) return;

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
      setState(() {
        _isSubmitting = false;
        _isSent = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.messageSavedEmailOpened)),
      );

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isSent = false;
            _robotChecked = false;
          });
          _clearForm();
        }
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
      _messageCountText = AppLocalizations.of(context)?.countCharacters(0) ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const accentGold = Color(0xFFC19A6B);
    final controller = Provider.of<HomePageController>(context);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return UserPageLayout(
      controller: controller,
      child: VisibilityDetector(
        key: const Key('contact-page-visibility'),
        onVisibilityChanged: (info) {
          if (info.visibleFraction > 0.1 && !_isVisible) {
            setState(() => _isVisible = true);
          }
        },
        child: Column(
          children: [
            const SizedBox(height: 120),
        
            if (controller.contactPageData.bannerImageUrl.isNotEmpty)
              FadeIn(
                duration: const Duration(milliseconds: 1000),
                child: ZoomOut(
                  duration: const Duration(milliseconds: 1500),
                  from: 1.1,
                  child: Container(
                    width: double.infinity,
                    height: 450,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(controller.contactPageData.bannerImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.4)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        
            const SizedBox(height: 80),
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              animate: _isVisible,
              child: Text(
                AppLocalizations.of(context)!.contactUs,
                style: AppTypography.headingStyle(
                  context,
                  fontSize: AppTypography.getResponsiveSize(context, desktop: 56, tablet: 48, mobile: 38),
                  fontWeight: FontWeight.w900,
                  color: primaryTeal,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 200),
              animate: _isVisible,
              child: Text(
                '${AppLocalizations.of(context)!.home} > ${AppLocalizations.of(context)!.contactUs}',
                style: TextStyle(
                  color: primaryTeal.withOpacity(0.6),
                  fontSize: 16,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        
            const SizedBox(height: 80),
        
            FadeInDown(
              animate: _isVisible,
              delay: const Duration(milliseconds: 400),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.enquiries,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryTeal,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(height: 2, width: 40, color: accentGold),
                ],
              ),
            ),
        
            SizedBox(height: isMobile ? 40 : 80),
        
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 15 : 100),
              child: Column(
                children: [
                  FadeIn(
                    animate: _isVisible,
                    delay: const Duration(milliseconds: 600),
                    child: Text(
                      AppLocalizations.of(context)!.siteQueryDisclaimer,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: isMobile ? 14 : 16, height: 1.6),
                    ),
                  ),
                  SizedBox(height: isMobile ? 40 : 80),
                  _buildForm(controller, primaryTeal, accentGold, isMobile),
                ],
              ),
            ),
        
            const SizedBox(height: 80),
            _buildSocialSection(controller, primaryTeal, accentGold, isMobile),

            const SizedBox(height: 120),
            UserFooter(controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(HomePageController controller, Color primaryTeal, Color accentGold, bool isMobile) {
    return Form(
      key: _formKey,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        padding: EdgeInsets.all(isMobile ? 24 : 60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 50,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobile) ...[
              _buildStaggeredField(0, 'name', AppLocalizations.of(context)!.nameLabel, _nameController, primaryTeal, accentGold),
              const SizedBox(height: 30),
              _buildStaggeredField(1, 'email', AppLocalizations.of(context)!.emailLabel, _emailController, primaryTeal, accentGold),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStaggeredField(0, 'name', AppLocalizations.of(context)!.nameLabel, _nameController, primaryTeal, accentGold),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: _buildStaggeredField(1, 'email', AppLocalizations.of(context)!.emailLabel, _emailController, primaryTeal, accentGold),
                  ),
                ],
              ),
            ],
            SizedBox(height: isMobile ? 30 : 40),
            
            if (isMobile) ...[
              _buildStaggeredField(2, 'mobile', AppLocalizations.of(context)!.telMobileLabel, _mobileController, primaryTeal, accentGold),
              const SizedBox(height: 30),
              _buildStaggeredField(3, 'country', AppLocalizations.of(context)!.countryLabel, _countryController, primaryTeal, accentGold),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStaggeredField(2, 'mobile', AppLocalizations.of(context)!.telMobileLabel, _mobileController, primaryTeal, accentGold),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: _buildStaggeredField(3, 'country', AppLocalizations.of(context)!.countryLabel, _countryController, primaryTeal, accentGold),
                  ),
                ],
              ),
            ],
            SizedBox(height: isMobile ? 30 : 40),
            
            _buildStaggeredField(4, 'message', AppLocalizations.of(context)!.messageLabel, _messageController, primaryTeal, accentGold, maxLines: 5),
            
            const SizedBox(height: 12),
            FadeInUp(
              animate: _isVisible,
              delay: const Duration(milliseconds: 1000),
              child: Text(
                _messageCountText,
                style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 50),

            FadeInUp(
              animate: _isVisible,
              delay: const Duration(milliseconds: 1100),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFFBFBFB),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      activeColor: primaryTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      value: _robotChecked,
                      onChanged: (value) => setState(() {
                        _robotChecked = value ?? false;
                        _errorText = null;
                      }),
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.imNotRobot,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Icon(Icons.refresh, color: Colors.blue, size: 24),
                  ],
                ),
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 15),
              FadeInDown(
                child: Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],

            const SizedBox(height: 60),

            FadeInUp(
              animate: _isVisible,
              delay: const Duration(milliseconds: 1200),
              child: Center(
                child: _AnimatedSubmitButton(
                  isSubmitting: _isSubmitting,
                  isSent: _isSent,
                  primaryColor: primaryTeal,
                  accentColor: accentGold,
                  onPressed: () => _submitForm(controller),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaggeredField(int index, String key, String label, TextEditingController controller, Color primaryTeal, Color accentGold, {int maxLines = 1}) {
    return FadeInUp(
      animate: _isVisible,
      duration: const Duration(milliseconds: 600),
      delay: Duration(milliseconds: 600 + (index * 80)),
      child: _ShakeableFormField(
        key: _fieldKeys[key],
        label: label,
        controller: controller,
        primaryTeal: primaryTeal,
        accentGold: accentGold,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildSocialSection(HomePageController controller, Color primaryTeal, Color accentGold, bool isMobile) {
    return Column(
      children: [
        FadeInUp(
          animate: _isVisible,
          delay: const Duration(milliseconds: 1300),
          child: const Text(
            "CONNECT WITH US",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 4, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialIcon(icon: Icons.facebook, color: const Color(0xFF1877F2), delay: 1400, url: controller.footer.facebookUrl),
            _SocialIcon(icon: Icons.camera_alt_rounded, color: const Color(0xFFE4405F), delay: 1500, url: controller.footer.instagramUrl),
            _SocialIcon(icon: Icons.play_circle_filled_rounded, color: const Color(0xFFFF0000), delay: 1600, url: controller.footer.youtubeUrl),
            _SocialIcon(icon: Icons.chat_bubble_rounded, color: const Color(0xFF25D366), delay: 1700, url: controller.footer.whatsappUrl),
          ],
        ),
      ],
    );
  }
}

class _ShakeableFormField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final Color primaryTeal;
  final Color accentGold;
  final int maxLines;

  const _ShakeableFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.primaryTeal,
    required this.accentGold,
    this.maxLines = 1,
  });

  @override
  State<_ShakeableFormField> createState() => _ShakeableFormFieldState();
}

class _ShakeableFormFieldState extends State<_ShakeableFormField> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void shake() {
    _shakeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 8.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reverse();
        }
      });

    return AnimatedBuilder(
      animation: offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(offsetAnimation.value * ( ( (_shakeController.value * 10).toInt() % 2 == 0) ? 1 : -1), 0),
          child: child,
        );
      },
      child: Focus(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        child: TextFormField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          validator: (value) {
            bool isInvalid = false;
            if (value == null || value.trim().isEmpty) isInvalid = true;
            if (widget.label.contains('Email') &&
                value != null && !RegExp(r"^[^\@\s]+@[^\@\s]+\.[^\@\s]+$").hasMatch(value.trim())) {
              isInvalid = true;
            }
            if (isInvalid) {
              shake();
              return widget.label.contains('Email') && value?.isNotEmpty == true 
                ? AppLocalizations.of(context)!.invalidEmail 
                : AppLocalizations.of(context)!.requiredField;
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: widget.label.toUpperCase(),
            labelStyle: TextStyle(
              color: _isFocused ? widget.accentGold : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: _isFocused ? Colors.white : const Color(0xFFFBFBFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.accentGold, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            errorStyle: const TextStyle(fontWeight: FontWeight.bold, height: 1.5),
          ),
        ),
      ),
    );
  }
}

class _AnimatedSubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final bool isSent;
  final Color primaryColor;
  final Color accentColor;
  final VoidCallback onPressed;

  const _AnimatedSubmitButton({
    required this.isSubmitting,
    required this.isSent,
    required this.primaryColor,
    required this.accentColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: isSubmitting ? 80 : (isSent ? 220 : 250),
      height: 70,
      child: ElevatedButton(
        onPressed: isSubmitting || isSent ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSent ? Colors.green : primaryColor,
          disabledBackgroundColor: isSent ? Colors.green : primaryColor.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSubmitting ? 35 : 12),
          ),
          padding: EdgeInsets.zero,
          elevation: isSubmitting ? 0 : 10,
          shadowColor: (isSent ? Colors.green : primaryColor).withOpacity(0.4),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isSubmitting
              ? const SizedBox(
                  width: 30, height: 30,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
              : isSent
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElasticIn(child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 28)),
                        const SizedBox(width: 12),
                        const Text("MESSAGE SENT!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ],
                    )
                  : Text(
                      AppLocalizations.of(context)!.sendMessage.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14),
                    ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final int delay;
  final String url;

  const _SocialIcon({required this.icon, required this.color, required this.delay, required this.url});

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _isHovered = false;

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: Duration(milliseconds: widget.delay),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () => _launchUrl(widget.url),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: _isHovered ? widget.color : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isHovered ? widget.color : Colors.black).withOpacity(0.1),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: const Offset(0, 5),
                ),
                if (_isHovered)
                  BoxShadow(
                    color: widget.color.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
              ],
            ),
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 300),
              turns: _isHovered ? 0.05 : 0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: _isHovered ? 1.2 : 1.0,
                child: Icon(
                  widget.icon,
                  color: _isHovered ? Colors.white : widget.color,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
