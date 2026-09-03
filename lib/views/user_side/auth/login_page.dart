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
              color: Colors.black.withOpacity(0.7), // Darker backdrop
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // ── Card ─────────────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: GestureDetector(
                  onTap: () {}, // absorb taps inside card
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
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
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
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
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return SiteElevatedButton(
      onPressed: _buttonState == 0 ? onPressed : null,
      enableHoverLift: false, // Cleaner for auth forms
      backgroundColor: _buttonState == 2 ? Colors.green : primaryTeal,
      borderRadius: BorderRadius.circular(12),
      padding: EdgeInsets.zero,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buttonState == 1
              ? const SizedBox(
                  key: ValueKey('spinner'),
                  height: 20, width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : _buttonState == 2
                  ? const Row(
                      key: ValueKey('success'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white, size: 24),
                        SizedBox(width: 10),
                        Text("SUCCESS", style: TextStyle(fontWeight: FontWeight.w900)),
                      ],
                    )
                  : Text(
                      key: const ValueKey('label'),
                      label.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
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
