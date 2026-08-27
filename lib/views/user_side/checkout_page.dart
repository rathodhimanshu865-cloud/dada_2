import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../utils/app_typography.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 1;
  String _deliveryMode = 'express';

  // Controllers for details
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color accentGold = const Color(0xFFC89A5B);
  final Color actionColor = const Color(0xFF071C21);

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Provider.of<CartController>(context);
    
    if (cartController.items.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 20),
              Text('Your bag is empty', style: AppTypography.headingStyle(context, fontSize: 24)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/product'),
                child: const Text('Back to Products'),
              ),
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 40, offset: const Offset(0, 10))],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(),
                    _buildStepper(),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 650) {
                          return Column(
                            children: [
                              _buildOrderSummary(context, cartController),
                              _buildDeliveryForm(),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildDeliveryForm()),
                            Expanded(flex: 2, child: _buildOrderSummary(context, cartController)),
                          ],
                        );
                      },
                    ),
                    _buildFooterActions(),
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
          _stepItem(1, 'Delivery Address', isActive: _currentStep == 1),
          _stepItem(2, 'Payment Options', isActive: _currentStep == 2),
          _stepItem(3, 'Order Placed', isActive: _currentStep == 3),
        ],
      ),
    );
  }

  Widget _stepItem(int index, String label, {bool isActive = false}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
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
          Text('Devotee Delivery Details', style: AppTypography.headingStyle(context, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Enter your address for consecrated dispatch and sacred blessings updates.', style: AppTypography.bodyStyle(context, color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: _formField('Devotee Full Name *', 'Himanshu Rathod', controller: _nameCtrl)),
              const SizedBox(width: 20),
              Expanded(child: _formField('WhatsApp / Phone Number *', '+91 98765 43210', controller: _phoneCtrl)),
            ],
          ),
          const SizedBox(height: 20),
          _formField('Email Address (for Digital Tax Invoice) *', 'rathodhimanshu865@gmail.com', controller: _emailCtrl),
          const SizedBox(height: 20),
          _formField('House / Flat No., Society & Street Address *', 'B-402, Radhe Krishna Residency, Near Temple Road', controller: _addressCtrl),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _formField('City *', 'Ahmedabad', controller: _cityCtrl)),
              const SizedBox(width: 20),
              Expanded(child: _formField('State *', 'Gujarat', controller: _stateCtrl)),
              const SizedBox(width: 20),
              Expanded(child: _formField('Pincode *', '380015', controller: _pinCtrl)),
            ],
          ),
          const SizedBox(height: 30),
          Text('Select Delivery Mode', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _deliveryOption('standard', 'Standard Sacred Delivery (4-6 Days)', '₹ 49')),
              const SizedBox(width: 15),
              Expanded(child: _deliveryOption('express', 'Express Air Dispatch (2-3 Days)', '₹ 99 • Priority tamper-proof pack', isFast: true)),
            ],
          ),
          const SizedBox(height: 30),
          _formField('Special Devotional Packing Note (Optional)', 'Please pack with consecrated Ganga Jal vial...', controller: _noteCtrl, maxLines: 2),
        ],
      ),
    );
  }

  Widget _formField(String label, String hint, {required TextEditingController controller, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodyStyle(context, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: primaryTeal, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _deliveryOption(String value, String label, String sub, {bool isFast = false}) {
    bool selected = _deliveryMode == value;
    return GestureDetector(
      onTap: () => setState(() => _deliveryMode = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? primaryTeal : Colors.grey.shade200, width: selected ? 1.5 : 1),
          color: selected ? primaryTeal.withOpacity(0.02) : Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? primaryTeal : Colors.grey.shade300, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(label, style: AppTypography.bodyStyle(context, fontSize: 13, fontWeight: FontWeight.bold))),
                      if (isFast) Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: accentGold, borderRadius: BorderRadius.circular(4)), child: const Text('FAST', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(sub, style: AppTypography.bodyStyle(context, fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartController cart) {
    bool isMobile = MediaQuery.of(context).size.width < 650;
    return Container(
      margin: EdgeInsets.only(
        top: 32,
        right: isMobile ? 32 : 32,
        left: isMobile ? 32 : 0,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          ...cart.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: item.product.imageUrls.isNotEmpty
                      ? Image.network(
                          item.product.imageUrls[0],
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 40,
                            height: 40,
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.broken_image_outlined, size: 20, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.image_outlined, size: 20, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: AppTypography.bodyStyle(context, fontSize: 12, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Qty: ${item.quantity}',
                        style: AppTypography.bodyStyle(context, fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('₹${(item.product.price * item.quantity).toStringAsFixed(2)}', style: AppTypography.bodyStyle(context, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          )),
          const Divider(height: 30),
          _summaryItem('Subtotal', '₹${cart.subtotal.toStringAsFixed(2)}'),
          _summaryItem('Shipping', '₹${cart.shippingFee.toStringAsFixed(2)}'),
          _summaryItem('Taxes (8%)', '₹${cart.tax.toStringAsFixed(2)}'),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: AppTypography.headingStyle(context, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('₹${cart.total.toStringAsFixed(2)}', style: AppTypography.headingStyle(context, fontSize: 16, fontWeight: FontWeight.bold, color: primaryTeal)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(Icons.verified, color: Colors.green.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text('Consecrated items with divine energy will be dispatched.', style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyStyle(context, fontSize: 13, color: Colors.grey.shade600)),
          Text(value, style: AppTypography.bodyStyle(context, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFooterActions() {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 280,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Final order logic
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order processing...'), backgroundColor: Color(0xFF0F4C5C)));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Proceed to Payment Options', style: AppTypography.bodyStyle(context, fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)), border: Border(top: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        children: [
          const Icon(Icons.security, size: 14, color: Colors.green),
          const SizedBox(width: 8),
          Text('256-Bit SSL Encrypted & RBI Verified Checkout', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('Support: +91 98765 43210', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
