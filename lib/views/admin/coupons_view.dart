import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/coupon_controller.dart';
import '../../models/coupon_model.dart';

class CouponsView extends StatelessWidget {
  const CouponsView({super.key});

  @override
  Widget build(BuildContext context) {
    final couponCtrl = Provider.of<CouponController>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Coupons & Devotional Offers', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Create promo codes and celebratory blessing discounts for devotees.', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showCouponDialog(context, couponCtrl),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('CREATE PROMO CODE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          if (couponCtrl.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (couponCtrl.coupons.isEmpty)
            const Center(child: Text('No coupons created yet.'))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: couponCtrl.coupons.length,
              itemBuilder: (context, i) => _buildCouponCard(context, couponCtrl.coupons[i], couponCtrl),
            ),
        ],
      ),
    );
  }

  Widget _buildCouponCard(BuildContext context, CouponModel coupon, CouponController ctrl) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(4)),
                child: Text(coupon.code, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(4)),
                child: Text(coupon.isActive ? 'ACTIVE' : 'INACTIVE', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.teal)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            coupon.discountType == 'percentage' 
              ? '${coupon.discountValue}% instant discount on all Dada products'
              : 'Flat ₹${coupon.discountValue} OFF on orders above ₹${coupon.minOrderValue}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Text('Discount: ${coupon.discountType == 'percentage' ? '${coupon.discountValue}%' : '₹${coupon.discountValue}'}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          Text('Min Order: ₹${coupon.minOrderValue}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text('Times Used: 412', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(onPressed: () => ctrl.deleteCoupon(coupon.id), icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  void _showCouponDialog(BuildContext context, CouponController ctrl) {
    final codeCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final minOrderCtrl = TextEditingController();
    final limitCtrl = TextEditingController(text: '2');
    final termsCtrl = TextEditingController(text: 'Maximum 2 uses per devotee.');
    String type = 'flat';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Promo Code'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Coupon Code (e.g. DADA10)')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: type,
                  items: const [
                    DropdownMenuItem(value: 'flat', child: Text('Flat Price Discount')),
                    DropdownMenuItem(value: 'percentage', child: Text('Percentage Discount')),
                  ],
                  onChanged: (v) => setDialogState(() => type = v!),
                  decoration: const InputDecoration(labelText: 'Discount Type'),
                ),
                const SizedBox(height: 16),
                TextField(controller: valueCtrl, decoration: InputDecoration(labelText: type == 'flat' ? 'Discount Value (₹)' : 'Discount Percentage (%)')),
                const SizedBox(height: 16),
                TextField(controller: minOrderCtrl, decoration: const InputDecoration(labelText: 'Minimum Order Value (₹)')),
                const SizedBox(height: 16),
                TextField(controller: limitCtrl, decoration: const InputDecoration(labelText: 'Usage Limit Per User'), keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                TextField(controller: termsCtrl, decoration: const InputDecoration(labelText: 'Terms & Conditions'), maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await ctrl.addCoupon(CouponModel(
                  id: '',
                  code: codeCtrl.text,
                  discountType: type,
                  discountValue: double.tryParse(valueCtrl.text) ?? 0,
                  minOrderValue: double.tryParse(minOrderCtrl.text) ?? 0,
                  usageLimitPerUser: int.tryParse(limitCtrl.text) ?? 2,
                  terms: termsCtrl.text,
                ));
                if (context.mounted) Navigator.pop(context);
              }, 
              child: const Text('Save Coupon')
            ),
          ],
        ),
      ),
    );
  }
}
