import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:dada_2/l10n/app_localizations.dart';
import 'package:animate_do/animate_do.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/app_typography.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  // ── Tab state ─────────────────────────────────────────────────────────────
  late AnimationController _tabController;
  int _activeTab = 0; // 0 = Sign In, 1 = Create Account

  // ── Controllers ───────────────────────────────────────────────────────────
  final _loginEmailCtrl       = TextEditingController();
  final _loginPassCtrl        = TextEditingController();
  final _signupNameCtrl       = TextEditingController();
  final _signupPhoneCtrl      = TextEditingController();
  final _signupEmailCtrl      = TextEditingController();
  final _signupPassCtrl       = TextEditingController();
  final _signupConfirmPassCtrl = TextEditingController();

  // ── Field focus nodes (for animated border color) ─────────────────────────
  final _loginEmailFocus   = FocusNode();
  final _loginPassFocus    = FocusNode();
  final _signupNameFocus   = FocusNode();
  final _signupPhoneFocus  = FocusNode();
  final _signupEmailFocus  = FocusNode();
  final _signupPassFocus   = FocusNode();
  final _signupConfirmFocus = FocusNode();

  // ── UI state ──────────────────────────────────────────────────────────────
  // 0 = idle, 1 = loading, 2 = success, 3 = error
  int _buttonState = 0;
  bool _obscurePass        = true;
  bool _obscureConfirmPass = true;
  String? _errorText;

  // ── Shake animation ───────────────────────────────────────────────────────
  late AnimationController _shakeCtrl;
  late Animation<double>   _shakeAnim;

  // ── Card entrance ─────────────────────────────────────────────────────────
  late AnimationController _cardCtrl;
  late Animation<double>   _cardOpacity;
  late Animation<double>   _cardScale;

  // ── Colors ────────────────────────────────────────────────────────────────
  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color accentGold  = const Color(0xFFC89A5B);

  @override
  void initState() {
    super.initState();

    // Tab slide animation
    _tabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Card entrance (scale+fade, 350ms)
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _cardOpacity = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _cardScale   = Tween<double>(begin: 0.96, end: 1.0)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));
    _cardCtrl.forward();

    // Shake animation
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -5.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.linear));

    // Listen to focus nodes to trigger rebuilds for border color
    for (final fn in [
      _loginEmailFocus, _loginPassFocus,
      _signupNameFocus, _signupPhoneFocus,
      _signupEmailFocus, _signupPassFocus, _signupConfirmFocus,
    ]) {
      fn.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardCtrl.dispose();
    _shakeCtrl.dispose();
    _loginEmailCtrl.dispose(); _loginPassCtrl.dispose();
    _signupNameCtrl.dispose(); _signupPhoneCtrl.dispose();
    _signupEmailCtrl.dispose(); _signupPassCtrl.dispose();
    _signupConfirmPassCtrl.dispose();
    _loginEmailFocus.dispose(); _loginPassFocus.dispose();
    _signupNameFocus.dispose(); _signupPhoneFocus.dispose();
    _signupEmailFocus.dispose(); _signupPassFocus.dispose();
    _signupConfirmFocus.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _switchTab(int index) {
    setState(() {
      _activeTab = index;
      _errorText = null;
    });
  }

  Future<void> _shake() async {
    _shakeCtrl.reset();
    await _shakeCtrl.forward();
  }

  void _setError(String msg) {
    setState(() {
      _errorText = msg;
      _buttonState = 0;
    });
    _shake();
  }

  // ── Login ────────────────────────────────────────────────────────────────

  Future<void> _handleLogin() async {
    final email    = _loginEmailCtrl.text.trim();
    final password = _loginPassCtrl.text.trim();
    final l10n     = AppLocalizations.of(context)!;
    if (email.isEmpty || password.isEmpty) {
      _setError(l10n.enterEmailPassword);
      return;
    }
    setState(() { _buttonState = 1; _errorText = null; });
    try {
      final auth = Provider.of<AuthController>(context, listen: false);
      await auth.login(email, password);
      if (mounted) {
        setState(() => _buttonState = 2);
        await Future.delayed(const Duration(milliseconds: 900));
        if (mounted) auth.toggleLoginPortal(false);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = l10n.loginFailed;
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              errorMessage = l10n.noAccountFound; break;
            case 'wrong-password':
            case 'invalid-credential':
              errorMessage = l10n.incorrectCredentials; break;
            case 'invalid-email':
              errorMessage = l10n.enterValidEmail; break;
            case 'user-disabled':
              errorMessage = l10n.accountDisabled; break;
            case 'too-many-requests':
              errorMessage = l10n.tooManyAttempts; break;
            default:
              errorMessage = e.message ?? errorMessage;
          }
        }
        _setError(errorMessage);
      }
    }
  }

  // ── Forgot password ───────────────────────────────────────────────────────

  Future<void> _handleForgotPassword() async {
    final email = _loginEmailCtrl.text.trim();
    final l10n  = AppLocalizations.of(context)!;
    if (email.isEmpty) { _setError(l10n.enterEmailFirst); return; }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.passwordResetSent(email)),
          backgroundColor: Colors.green,
        ));
      }
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? l10n.failedSendResetEmail);
    }
  }

  // ── Sign up ───────────────────────────────────────────────────────────────

  Future<void> _handleSignup() async {
    final name            = _signupNameCtrl.text.trim();
    final phone           = _signupPhoneCtrl.text.trim();
    final email           = _signupEmailCtrl.text.trim();
    final password        = _signupPassCtrl.text.trim();
    final confirmPassword = _signupConfirmPassCtrl.text.trim();
    final l10n            = AppLocalizations.of(context)!;

    if (name.isEmpty || phone.isEmpty || email.isEmpty ||
        password.isEmpty || confirmPassword.isEmpty) {
      _setError(l10n.allFieldsRequired);
      return;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) { _setError(l10n.enterValidEmail); return; }

    final phoneRegex = RegExp(r'^\+?[0-9]{10,12}$');
    if (!phoneRegex.hasMatch(phone)) { _setError(l10n.enterValidPhone); return; }

    if (password.length < 8) { _setError(l10n.passwordTooShort); return; }
    if (password != confirmPassword) { _setError(l10n.passwordsDoNotMatch); return; }

    setState(() { _buttonState = 1; _errorText = null; });
    try {
      await Provider.of<AuthController>(context, listen: false).signUp(
        email: email, password: password, fullName: name, phone: phone,
      );
      if (mounted) {
        setState(() => _buttonState = 2);
        await Future.delayed(const Duration(milliseconds: 900));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.accountCreatedSuccess),
            backgroundColor: Colors.green,
          ));
          Provider.of<AuthController>(context, listen: false).toggleLoginPortal(false);
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = l10n.loginFailed;
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'The email address is already in use by another account.'; break;
            case 'invalid-email':
              errorMessage = l10n.enterValidEmail; break;
            case 'weak-password':
              errorMessage = 'The password is too weak.'; break;
            default:
              errorMessage = e.message ?? errorMessage;
          }
        }
        _setError(errorMessage);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context, listen: false);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // ── Backdrop ─────────────────────────────────────────────────────
          GestureDetector(
            onTap: () => auth.toggleLoginPortal(false),
            child: Container(
              color: Colors.black54,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // ── Card (scale + fade entrance) ─────────────────────────────────
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: GestureDetector(
                  onTap: () {}, // absorb taps inside card
                  child: ScaleTransition(
                    scale: _cardScale,
                    child: FadeTransition(
                      opacity: _cardOpacity,
                      child: AnimatedBuilder(
                        animation: _shakeAnim,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(_shakeAnim.value, 0),
                          child: child,
                        ),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 450),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeader(auth),
                              const SizedBox(height: 24),
                              _buildTabSwitcher(),
                              _buildForms(),
                              _buildFooter(),
                            ],
                          ),
                        ),
                      ),
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

  // ─────────────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeader(AuthController auth) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryTeal, primaryTeal.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: FadeInDown(
        duration: const Duration(milliseconds: 300),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_person_outlined, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                l10n.sacredAccessPortal,
                style: AppTypography.headingStyle(
                  context, color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: () => auth.toggleLoginPortal(false),
              icon: const Icon(Icons.close, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB SWITCHER (sliding pill)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTabSwitcher() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double boxWidth = constraints.maxWidth;
            return Stack(
              children: [
                // Sliding pill
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: _activeTab == 0 ? Alignment.centerLeft : Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      width: (boxWidth - 8) / 2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                    ),
                  ),
                ),
                // Tab labels
                Row(
                  children: [
                    Expanded(child: _tabLabel(l10n.signIn, 0)),
                    Expanded(child: _tabLabel(l10n.createAccount, 1)),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _tabLabel(String text, int index) {
    return GestureDetector(
      onTap: () => _switchTab(index),
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1,
            color: _activeTab == index ? primaryTeal : Colors.grey,
          ),
          child: Text(text),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FORMS (AnimatedSwitcher with fade+slide)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildForms() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
      child: _activeTab == 0
          ? _buildLoginForm()
          : _buildSignupForm(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOGIN FORM
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildLoginForm() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      key: const ValueKey('login_form'),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error text
          if (_errorText != null)
            FadeInDown(
              key: ValueKey(_errorText),
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 16, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorText!, style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
              ),
            ),

          // Email field (staggered FadeInUp)
          FadeInUp(delay: const Duration(milliseconds: 80), duration: const Duration(milliseconds: 300), from: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel(l10n.emailAddressLabel),
                _buildTextField(_loginEmailCtrl, Icons.email_outlined, 'email@example.com', focusNode: _loginEmailFocus),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Password field
          FadeInUp(delay: const Duration(milliseconds: 160), duration: const Duration(milliseconds: 300), from: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFieldLabel(l10n.password),
                    _buildHoverLink(l10n.forgotPassword, _handleForgotPassword),
                  ],
                ),
                _buildTextField(_loginPassCtrl, Icons.lock_outline, '••••••••',
                    isPassword: true, focusNode: _loginPassFocus),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Submit button
          FadeInUp(delay: const Duration(milliseconds: 240), duration: const Duration(milliseconds: 300), from: 12,
            child: _buildActionButton(l10n.loginToAccount, _handleLogin),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SIGNUP FORM
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSignupForm() {
    final l10n = AppLocalizations.of(context)!;

    final fields = [
      (l10n.fullNameLabel,        _signupNameCtrl,        Icons.person_outline,   'Your Name',        false, _signupNameFocus,    false),
      (l10n.mobileWhatsAppLabel,  _signupPhoneCtrl,       Icons.phone_outlined,    '+91 00000 00000',  false, _signupPhoneFocus,   false),
      (l10n.emailAddressLabel,    _signupEmailCtrl,       Icons.email_outlined,    'email@example.com',false, _signupEmailFocus,   false),
      (l10n.securePasswordLabel,  _signupPassCtrl,        Icons.lock_outline,      '••••••••',          true,  _signupPassFocus,    false),
      (l10n.confirmPasswordLabel, _signupConfirmPassCtrl, Icons.lock_outline,      '••••••••',          true,  _signupConfirmFocus, true),
    ];

    return Padding(
      key: const ValueKey('signup_form'),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Error text
          if (_errorText != null)
            FadeInDown(
              key: ValueKey(_errorText),
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 16, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorText!, style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
              ),
            ),

          // Staggered fields
          ...fields.asMap().entries.map((e) {
            final i   = e.key;
            final f   = e.value;
            return FadeInUp(
              delay: Duration(milliseconds: 80 * (i + 1)),
              duration: const Duration(milliseconds: 300),
              from: 12,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(f.$1),
                    _buildTextField(f.$2, f.$3, f.$4,
                      isPassword: f.$5, focusNode: f.$6, isConfirm: f.$7),
                  ],
                ),
              ),
            );
          }),

          // Submit button
          FadeInUp(
            delay: Duration(milliseconds: 80 * (fields.length + 1)),
            duration: const Duration(milliseconds: 300),
            from: 12,
            child: _buildActionButton(l10n.joinCommunity, _handleSignup),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHARED FIELD WIDGETS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.bodyStyle(context,
            fontSize: 10, fontWeight: FontWeight.w800,
            color: Colors.grey.shade500, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    IconData icon,
    String hint, {
    bool isPassword  = false,
    bool isConfirm   = false,
    FocusNode? focusNode,
  }) {
    final isFocused = focusNode?.hasFocus ?? false;
    final isObscure = isPassword && (isConfirm ? _obscureConfirmPass : _obscurePass);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? accentGold : Colors.grey.shade200,
          width: isFocused ? 1.5 : 1.0,
        ),
        boxShadow: isFocused
            ? [BoxShadow(color: accentGold.withOpacity(0.15), blurRadius: 8)]
            : [],
      ),
      child: TextField(
        controller: ctrl,
        focusNode: focusNode,
        obscureText: isObscure,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade300),
          prefixIcon: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(icon, size: 18,
                color: isFocused ? accentGold : primaryTeal.withOpacity(0.5)),
          ),
          suffixIcon: isPassword
              ? _buildEyeIcon(isConfirm: isConfirm)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildEyeIcon({bool isConfirm = false}) {
    final isObscure = isConfirm ? _obscureConfirmPass : _obscurePass;
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: Icon(
          isObscure ? Icons.visibility_off : Icons.visibility,
          key: ValueKey(isObscure),
          size: 18,
          color: Colors.grey,
        ),
      ),
      onPressed: () => setState(() {
        if (isConfirm) {
          _obscureConfirmPass = !_obscureConfirmPass;
        } else {
          _obscurePass = !_obscurePass;
        }
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACTION BUTTON (idle → loading → success / error)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: GestureDetector(
        onTap: _buttonState == 0 ? onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: _buttonState == 2
                ? Colors.green
                : _buttonState == 3
                    ? Colors.red.shade400
                    : primaryTeal,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _buttonState == 1
                  // Loading spinner
                  ? const SizedBox(
                      key: ValueKey('spinner'),
                      height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : _buttonState == 2
                      // Success checkmark
                      ? ZoomIn(
                          key: const ValueKey('success'),
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 26),
                        )
                      // Idle label
                      : Text(
                          key: const ValueKey('label'),
                          label.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HOVER LINK
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHoverLink(String text, VoidCallback onTap) {
    return _HoverUnderlineButton(
      text: text,
      color: accentGold,
      onTap: onTap,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FOOTER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    final l10n = AppLocalizations.of(context)!;
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
            l10n.secureAuthArea,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500,
                fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOVER UNDERLINE BUTTON (secondary links — quiet, no heavy motion)
// ─────────────────────────────────────────────────────────────────────────────

class _HoverUnderlineButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _HoverUnderlineButton({
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  State<_HoverUnderlineButton> createState() => _HoverUnderlineButtonState();
}

class _HoverUnderlineButtonState extends State<_HoverUnderlineButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.text,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 1,
                width: _hovered ? 100 : 0,
                color: widget.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
