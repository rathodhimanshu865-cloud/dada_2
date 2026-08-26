import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/app_typography.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  final _signupNameCtrl = TextEditingController();
  final _signupPhoneCtrl = TextEditingController();
  final _signupEmailCtrl = TextEditingController();
  final _signupPassCtrl = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePass = true;

  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color accentGold = const Color(0xFFC89A5B);

  @override
  void initState() {
    super.initState();
    // Defaulting to "Create New Account" (index 1) as requested
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _signupNameCtrl.dispose();
    _signupPhoneCtrl.dispose();
    _signupEmailCtrl.dispose();
    _signupPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthController>(context, listen: false)
          .login(_loginEmailCtrl.text.trim(), _loginPassCtrl.text.trim());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignup() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthController>(context, listen: false).signUp(
        email: _signupEmailCtrl.text.trim(),
        password: _signupPassCtrl.text.trim(),
        fullName: _signupNameCtrl.text.trim(),
        phone: _signupPhoneCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account Created Successfully! Please Login.'),
            backgroundColor: Colors.green,
          ),
        );
        _loginEmailCtrl.text = _signupEmailCtrl.text;
        _tabController.animateTo(0); // Switch to login tab
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
          errorMessage = 'Account already exists with this email. Please log in.';
          // Automatically switch to login tab and pre-fill email
          _loginEmailCtrl.text = _signupEmailCtrl.text;
          _tabController.animateTo(0);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.05),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  _buildTabs(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _tabController.index == 0 
                        ? _buildLoginForm() 
                        : _buildSignupForm(),
                  ),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryTeal, primaryTeal.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DADA Devotee Account',
                  style: AppTypography.headingStyle(context, color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Access your orders, trackings & sacred blessings',
                  style: AppTypography.bodyStyle(context, color: Colors.white.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (i) => setState(() {}),
        labelColor: primaryTeal,
        unselectedLabelColor: Colors.grey,
        indicatorColor: accentGold,
        indicatorWeight: 3,
        labelStyle: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 14),
        tabs: const [
          Tab(text: 'Sign In / Login'),
          Tab(text: 'Create New Account'),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      key: const ValueKey('login_form'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Email Address'),
          _buildTextField(_loginEmailCtrl, Icons.email_outlined, 'Enter email'),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFieldLabel('Password'),
              TextButton(
                onPressed: () {},
                child: Text('Forgot password?', style: TextStyle(color: accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          _buildTextField(_loginPassCtrl, Icons.lock_outline, '••••••••', isPassword: true),
          const SizedBox(height: 30),
          _buildActionButton('Sign In Securely', _handleLogin),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Padding(
      key: const ValueKey('signup_form'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Devotee Full Name'),
          _buildTextField(_signupNameCtrl, Icons.person_outline, 'Your Name'),
          const SizedBox(height: 16),
          _buildFieldLabel('WhatsApp / Phone Number'),
          _buildTextField(_signupPhoneCtrl, Icons.phone_outlined, '+91 00000 00000'),
          const SizedBox(height: 16),
          _buildFieldLabel('Email Address'),
          _buildTextField(_signupEmailCtrl, Icons.email_outlined, 'email@example.com'),
          const SizedBox(height: 16),
          _buildFieldLabel('Password'),
          _buildTextField(_signupPassCtrl, Icons.lock_outline, '••••••••', isPassword: true),
          const SizedBox(height: 24),
          _buildActionButton('Create Devotee Account', _handleSignup),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => _tabController.animateTo(0),
              child: Text('Already have an account? Sign In', 
                style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AppTypography.bodyStyle(context, fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, IconData icon, String hint, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: isPassword && _obscurePass,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: Colors.grey),
          suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, size: 18, color: Colors.grey),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ) 
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildInstantAccessSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade200)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'INSTANT 1-CLICK ACCESS',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 1.2),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade200)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildOutlineButton('Devotee Demo', () {}),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOutlineButton('Admin Login', () => Navigator.pushNamed(context, '/admin_login')),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOutlineButton(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: accentGold.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label, style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFooterItem(Icons.security, '256-Bit SSL Encrypted'),
          _buildFooterItem(Icons.check_circle_outline, 'Official DADA Store'),
        ],
      ),
    );
  }

  Widget _buildFooterItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.green.shade700),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
