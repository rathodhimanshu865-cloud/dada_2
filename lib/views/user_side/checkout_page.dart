import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/homepage_controller.dart';
import '../../utils/app_typography.dart';
import 'sections/user_page_layout.dart';
import 'sections/user_footer.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final Color _teal = const Color(0xFF0F4C5C);

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartController>(context);
    final auth = Provider.of<AuthController>(context);
    final home = Provider.of<HomePageController>(context);
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    if (!auth.isAuthenticated) {
      return _buildLoginRequired(home);
    }

    if (cart.items.isEmpty) {
      return _buildEmptyCartRedirect(home);
    }

    return UserPageLayout(
      controller: home,
      child: Column(
        children: [
          const SizedBox(height: 120),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80, vertical: 60),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CHECKOUT', style: AppTypography.headingStyle(context, fontSize: 32, fontWeight: FontWeight.bold, color: _teal)),
                    const SizedBox(height: 40),
                    isMobile ? _buildMobile(context, cart) : _buildDesktop(context, cart),
                  ],
                ),
              ),
            ),
          ),
          UserFooter(controller: home),
        ],
      ),
    );
  }

  Widget _buildLoginRequired(HomePageController home) {
    return UserPageLayout(
      controller: home,
      child: Container(
        height: 600,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text('LOGIN REQUIRED', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Please login or sign up to complete your purchase.'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(backgroundColor: _teal, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20)),
              child: const Text('LOGIN / SIGN UP'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCartRedirect(HomePageController home) {
    return UserPageLayout(
      controller: home,
      child: Container(
        height: 600,
        alignment: Alignment.center,
        child: const Text('Your cart is empty. Redirecting...'),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context, CartController cart) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildForm()),
        const SizedBox(width: 60),
        Expanded(child: _buildSummary(cart)),
      ],
    );
  }

  Widget _buildMobile(BuildContext context, CartController cart) {
    return Column(
      children: [
        _buildSummary(cart),
        const SizedBox(height: 40),
        _buildForm(),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SHIPPING DETAILS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 24),
          _field('Shipping Address', _addressCtrl, maxLines: 3),
          const SizedBox(height: 20),
          _field('Contact Number', _phoneCtrl, keyboardType: TextInputType.phone),
          const SizedBox(height: 40),
          const Text('PAYMENT METHOD', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(border: Border.all(color: _teal), borderRadius: BorderRadius.circular(8), color: _teal.withOpacity(0.05)),
            child: Row(
              children: [
                Icon(Icons.payment, color: _teal),
                const SizedBox(width: 16),
                const Text('Razorpay (Cards, UPI, Netbanking)', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (v) => v == null || v.isEmpty ? 'Field required' : null,
    );
  }

  Widget _buildSummary(CartController cart) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFFFAF8F4), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE9E4DE))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ORDER SUMMARY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 24),
          ...cart.items.values.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${item.product.title} x ${item.quantity}', style: const TextStyle(fontSize: 13)),
                Text('₹${item.total}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )).toList(),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('₹${cart.subtotal}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F4C5C))),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _startPayment,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 60)),
            child: const Text('PAY SECURELY NOW'),
          ),
        ],
      ),
    );
  }

  Future<void> _startPayment() async {
    if (!_formKey.currentState!.validate()) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Initializing Razorpay... (Implementation in next step)'))
    );
  }
}
