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
  final _signupConfirmPassCtrl = TextEditingController(); // Added
  
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirmPass = true; // Added

  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color accentGold = const Color(0xFFC89A5B);

  @override
  void initState() {
    super.initState();
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
    _signupConfirmPassCtrl.dispose(); // Added
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _loginEmailCtrl.text.trim();
    final password = _loginPassCtrl.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter your email and password');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthController>(context, listen: false);
      await auth.login(email, password);
      // Wait for role to be fetched from Firestore
      if (auth.role == null) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if (mounted) {
        auth.toggleLoginPortal(false);
        // Both User and Admin stay on the User-side panel (Home Page) by default as per request.
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Login Failed';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              errorMessage = 'No account found with this email.';
              break;
            case 'wrong-password':
            case 'invalid-credential':
              errorMessage = 'Incorrect email or password.';
              break;
            case 'invalid-email':
              errorMessage = 'Please enter a valid email address.';
              break;
            case 'user-disabled':
              errorMessage = 'This account has been disabled.';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many failed attempts. Please try again later.';
              break;
            default:
              errorMessage = e.message ?? errorMessage;
          }
        }
        _showError(errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _loginEmailCtrl.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email address above first');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to $email'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'Failed to send reset email');
    }
  }

  Future<void> _handleSignup() async {
    final name = _signupNameCtrl.text.trim();
    final phone = _signupPhoneCtrl.text.trim();
    final email = _signupEmailCtrl.text.trim();
    final password = _signupPassCtrl.text.trim();
    final confirmPassword = _signupConfirmPassCtrl.text.trim();

    // Validations
    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showError('All fields are required');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    final phoneRegex = RegExp(r'^\+?[0-9]{10,12}$');
    if (!phoneRegex.hasMatch(phone)) {
      _showError('Please enter a valid phone number (10-12 digits)');
      return;
    }

    if (password.length < 8) {
      _showError('Password must be at least 8 characters long');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthController>(context, listen: false).signUp(
        email: email,
        password: password,
        fullName: name,
        phone: phone,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account Created Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // After registration, automatically sign in and navigate to home screen
        Provider.of<AuthController>(context, listen: false).toggleLoginPortal(false);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Registration Failed';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'The email address is already in use by another account.';
              break;
            case 'invalid-email':
              errorMessage = 'The email address is not valid.';
              break;
            case 'weak-password':
              errorMessage = 'The password is too weak.';
              break;
            default:
              errorMessage = e.message ?? errorMessage;
          }
        }
        _showError(errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context, listen: false);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: () => auth.toggleLoginPortal(false),
            child: Container(
              color: Colors.black54,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          
          // Portal Box
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: GestureDetector(
                  onTap: () {}, // Prevent tap from closing when clicking inside the box
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(auth),
                        const SizedBox(height: 24),
                        _buildOverlappingSwitcher(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: animation.drive(Tween(begin: const Offset(0, 0.05), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut))),
                                child: child,
                              ),
                            );
                          },
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
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthController auth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryTeal, primaryTeal.withOpacity(0.9)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.lock_person_outlined, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Sacred Access Portal',
                  style: AppTypography.headingStyle(context, color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => auth.toggleLoginPortal(false),
                icon: const Icon(Icons.close, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverlappingSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: _tabController.index == 0 ? Alignment.centerLeft : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  width: (450 - 48 - 8) / 2, // Approx half width
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tabController.animateTo(0)),
                    child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Text(
                        'SIGN IN',
                        style: AppTypography.bodyStyle(context, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 12, 
                          color: _tabController.index == 0 ? primaryTeal : Colors.grey,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tabController.animateTo(1)),
                    child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Text(
                        'CREATE ACCOUNT',
                        style: AppTypography.bodyStyle(context, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 12, 
                          color: _tabController.index == 1 ? primaryTeal : Colors.grey,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      key: const ValueKey('login_form'),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Email Address'),
          _buildTextField(_loginEmailCtrl, Icons.email_outlined, 'email@example.com'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFieldLabel('Password'),
              TextButton(
                onPressed: _handleForgotPassword,
                child: Text('Forgot?', style: TextStyle(color: accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          _buildTextField(_loginPassCtrl, Icons.lock_outline, '••••••••', isPassword: true),
          const SizedBox(height: 32),
          _buildActionButton('Log In to Your Account', _handleLogin),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Padding(
      key: const ValueKey('signup_form'),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Full Name'),
          _buildTextField(_signupNameCtrl, Icons.person_outline, 'Your Name'),
          const SizedBox(height: 16),
          _buildFieldLabel('Mobile / WhatsApp'),
          _buildTextField(_signupPhoneCtrl, Icons.phone_outlined, '+91 00000 00000'),
          const SizedBox(height: 16),
          _buildFieldLabel('Email Address'),
          _buildTextField(_signupEmailCtrl, Icons.email_outlined, 'email@example.com'),
          const SizedBox(height: 16),
          _buildFieldLabel('Secure Password'),
          _buildTextField(_signupPassCtrl, Icons.lock_outline, '••••••••', isPassword: true),
          const SizedBox(height: 16),
          _buildFieldLabel('Confirm Password'),
          _buildTextField(_signupConfirmPassCtrl, Icons.lock_outline, '••••••••', isPassword: true, isConfirm: true),
          const SizedBox(height: 32),
          _buildActionButton('Join the Community', _handleSignup),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.bodyStyle(context, fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade500, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, IconData icon, String hint, {bool isPassword = false, bool isConfirm = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: isPassword && (isConfirm ? _obscureConfirmPass : _obscurePass),
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade300),
          prefixIcon: Icon(icon, size: 18, color: primaryTeal.withOpacity(0.5)),
          suffixIcon: isPassword 
              ? IconButton(
                  icon: Icon((isConfirm ? _obscureConfirmPass : _obscurePass) ? Icons.visibility_off : Icons.visibility, size: 18, color: Colors.grey),
                  onPressed: () => setState(() {
                    if (isConfirm) {
                      _obscureConfirmPass = !_obscureConfirmPass;
                    } else {
                      _obscurePass = !_obscurePass;
                    }
                  }),
                ) 
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Text(
            'Secure Devotee Authorization Area',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}
