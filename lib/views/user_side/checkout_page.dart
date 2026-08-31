import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/order_model.dart';
import '../../utils/app_typography.dart';
import '../../utils/invoice_helper.dart';
import 'package:flutter/services.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1;
  String _paymentMethod = 'COD';

  // Controllers for details
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Pre-fill user details if logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthController>(context, listen: false);
      if (auth.userModel != null) {
        _nameCtrl.text = auth.userModel!.name;
        _phoneCtrl.text = auth.userModel!.phone;
        _emailCtrl.text = auth.userModel!.email;
        _addressCtrl.text = auth.userModel!.address ?? '';
        _cityCtrl.text = auth.userModel!.city ?? '';
        _stateCtrl.text = auth.userModel!.state ?? '';
        _pinCtrl.text = auth.userModel!.pincode ?? '';
      }
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _handlePlaceOrder(paymentId: response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}'), backgroundColor: Colors.red),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet
  }

  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color accentGold = const Color(0xFFC89A5B);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pinCtrl.dispose();
    _noteCtrl.dispose();
    _razorpay.clear(); // Clear razorpay instance
    super.dispose();
  }

  Future<void> _startPayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_paymentMethod == 'COD') {
      await _handlePlaceOrder();
      return;
    }

    // Simulate Razorpay Gateway for now
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Razorpay Payment Gateway (Dummy)'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Processing secure payment...'),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context); // Close dummy gateway

    await _handlePlaceOrder(paymentId: 'pay_${DateTime.now().millisecondsSinceEpoch}');
  }

  String? _placedOrderId;
  OrderModel? _placedOrder;

  Future<void> _handlePlaceOrder({String? paymentId}) async {
    final cartController = Provider.of<CartController>(context, listen: false);
    final orderController = Provider.of<OrderController>(context, listen: false);
    final auth = Provider.of<AuthController>(context, listen: false);

    // Strict validation for Email and Pincode
    if (auth.userModel != null) {
      if (_emailCtrl.text.trim().toLowerCase() != auth.userModel!.email.toLowerCase()) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email must match your profile email.')));
         return;
      }
    }

    if (_pinCtrl.text.trim().length != 6) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid 6-digit pincode.')));
       return;
    }

    final orderId = await orderController.placeOrder(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      pincode: _pinCtrl.text.trim(),
      cartItems: cartController.items,
      subtotal: cartController.subtotal,
      deliveryCharge: cartController.shippingFee,
      tax: cartController.tax,
      discount: cartController.discountAmount,
      couponCode: cartController.appliedCoupon?.code,
      total: cartController.total,
      paymentMethod: paymentId != null ? 'Online ($paymentId)' : 'COD',
      note: _noteCtrl.text.trim(),
    );

    if (mounted) {
      if (orderId != null) {
        _placedOrderId = orderId;
        // Fetch the full order model for invoice generation
        orderController.getOrderDetails(orderId).first.then((order) {
          if (mounted) setState(() => _placedOrder = order);
        });

        await cartController.clearCart();
        
        // Send Notification
        final auth = Provider.of<AuthController>(context, listen: false);
        if (auth.user != null) {
          await Provider.of<NotificationController>(context, listen: false)
              .sendOrderNotification(
            userId: auth.user!.uid,
            orderId: orderId,
            status: 'Pending',
          );
        }

        setState(() => _currentStep = 3);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order Placed Successfully!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to place order.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Provider.of<CartController>(context);
    final orderController = Provider.of<OrderController>(context);
    
    if (_currentStep < 3 && cartController.items.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 20),
              Text('Your bag is empty', style: AppTypography.headingStyle(context, fontSize: 24)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/product'), child: const Text('Back to Products')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.03),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 40, offset: const Offset(0, 10))]),
              child: _currentStep == 3 ? _buildSuccessView() : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    _buildStepper(),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool isMobile = constraints.maxWidth < 650;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _currentStep == 1 ? _buildDeliveryForm() : _buildPaymentForm()),
                            if (!isMobile) Expanded(flex: 2, child: _buildOrderSummary(context, cartController)),
                          ],
                        );
                      },
                    ),
                    _buildFooterActions(orderController),
                    _buildBottomBar(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Text('DADA', style: AppTypography.headingStyle(context, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.black)),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: primaryTeal.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryTeal.withOpacity(0.2))),
            child: Text('SECURE SACRED CHECKOUT', style: AppTypography.bodyStyle(context, color: primaryTeal, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
          ),
          const Spacer(),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.grey, size: 20)),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
      decoration: BoxDecoration(color: Colors.grey.shade50, border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _stepItem(1, 'Address', isActive: _currentStep == 1),
          _stepItem(2, 'Payment', isActive: _currentStep == 2),
          _stepItem(3, 'Placed', isActive: _currentStep == 3),
        ],
      ),
    );
  }

  Widget _stepItem(int index, String label, {bool isActive = false}) {
    return Row(
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? primaryTeal : Colors.grey.shade200),
          alignment: Alignment.center,
          child: Text('$index', style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
        Text(label, style: AppTypography.bodyStyle(context, fontSize: 12, color: isActive ? Colors.black : Colors.grey.shade500, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildDeliveryForm() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery Details', style: AppTypography.headingStyle(context, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _formField('Full Name *', 'Himanshu Rathod', controller: _nameCtrl),
          const SizedBox(height: 20),
          _formField('Phone *', '+91 98765 43210', controller: _phoneCtrl, validator: (v) => (v == null || v.length < 10) ? 'Valid Phone Required' : null),
          const SizedBox(height: 20),
          _formField('Email *', 'devotee@example.com', controller: _emailCtrl, validator: (v) => (v == null || !v.contains('@')) ? 'Valid Email Required' : null),
          const SizedBox(height: 20),
          _formField('Address *', 'House No, Street...', controller: _addressCtrl, maxLines: 2),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _formField('City *', 'Ahmedabad', controller: _cityCtrl)),
            const SizedBox(width: 20),
            Expanded(child: _formField('State *', 'Gujarat', controller: _stateCtrl)),
          ]),
          const SizedBox(height: 20),
          _formField('Pincode *', '380015', controller: _pinCtrl, validator: (v) => (v == null || v.length < 6) ? 'Valid Pincode Required' : null),
          const SizedBox(height: 20),
          _formField('Note (Optional)', 'Notes...', controller: _noteCtrl, maxLines: 2, isMandatory: false),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Method', style: AppTypography.headingStyle(context, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _paymentOption('COD', 'Cash on Delivery', 'Pay when delivered.', Icons.handshake_outlined),
          const SizedBox(height: 20),
          _paymentOption('UPI', 'UPI / Online Payment', 'Secure online payment.', Icons.qr_code_scanner_outlined),
        ],
      ),
    );
  }

  Widget _paymentOption(String value, String title, String sub, IconData icon) {
    bool selected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? primaryTeal : Colors.grey.shade200, width: selected ? 2 : 1), color: selected ? primaryTeal.withOpacity(0.02) : Colors.white),
        child: Row(children: [Icon(icon, color: selected ? primaryTeal : Colors.grey, size: 24), const SizedBox(width: 20), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), Text(sub, style: TextStyle(color: Colors.grey.shade500, fontSize: 12))])), Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? primaryTeal : Colors.grey.shade300, size: 20)]),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartController cart) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Summary', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 30),
          _summaryRow('Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}'),
          if (cart.discountAmount > 0)
            _summaryRow('Discount', '- ₹${cart.discountAmount.toStringAsFixed(2)}'),
          _summaryRow('Shipping', '₹${cart.shippingFee.toStringAsFixed(2)}'),
          _summaryRow('Taxes', '₹${cart.tax.toStringAsFixed(2)}'),
          const Divider(),
          _summaryRow('Total', '₹${cart.total.toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)), Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal))]),
    );
  }

  Widget _buildFooterActions(OrderController orderController) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep == 2) TextButton.icon(onPressed: () => setState(() => _currentStep = 1), icon: const Icon(Icons.arrow_back), label: const Text('Back')),
          ElevatedButton(
            onPressed: orderController.isLoading ? null : () { 
              if (_currentStep == 1) { 
                if (_formKey.currentState!.validate()) {
                  setState(() => _currentStep = 2); 
                }
              } else {
                _startPayment(); 
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20)),
            child: orderController.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_currentStep == 1 ? 'Next' : 'Complete Order'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(padding: const EdgeInsets.all(16), child: const Center(child: Text('Secure Checkout', style: TextStyle(fontSize: 10, color: Colors.grey))));
  }

  Widget _buildSuccessView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 24),
          Text('Order Placed!', style: AppTypography.headingStyle(context, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Order ID: $_placedOrderId', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy, size: 16, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  if (_placedOrderId != null) {
                    Clipboard.setData(ClipboardData(text: _placedOrderId!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order ID copied to clipboard!'), behavior: SnackBarBehavior.floating),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
          if (_placedOrder != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => InvoiceHelper.printInvoice(_placedOrder!),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('Download Invoice', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, padding: const EdgeInsets.symmetric(vertical: 18)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => InvoiceHelper.shareToWhatsApp(_placedOrder!),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Send to WhatsApp', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), padding: const EdgeInsets.symmetric(vertical: 18)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/product', (route) => false), 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 18)),
              child: const Text('Continue Shopping'),
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/track', arguments: _placedOrderId), 
            icon: const Icon(Icons.track_changes, size: 16),
            label: const Text('Track Order Status'),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/my_orders'), 
            child: const Text('Go to My Orders'),
          ),
        ],
      ),
    );
  }

  Widget _formField(String label, String hint, {required TextEditingController controller, int maxLines = 1, String? Function(String?)? validator, bool isMandatory = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller, maxLines: maxLines,
          validator: validator ?? (isMandatory ? (v) => v == null || v.isEmpty ? 'Required' : null : null),
          decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        ),
      ],
    );
  }
}
