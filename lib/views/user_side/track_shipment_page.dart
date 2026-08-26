import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/homepage_controller.dart';
import '../../utils/app_typography.dart';
import 'sections/product_cart_layout.dart';

class TrackShipmentPage extends StatefulWidget {
  const TrackShipmentPage({super.key});

  @override
  State<TrackShipmentPage> createState() => _TrackShipmentPageState();
}

class _TrackShipmentPageState extends State<TrackShipmentPage> {
  final Color primaryTeal = const Color(0xFF0F4C5C);
  final Color accentGold = const Color(0xFFC89A5B);
  final TextEditingController _trackingController = TextEditingController();

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomePageController>(context, listen: false);

    return ProductCartLayout(
      controller: controller,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchSection(),
                        const SizedBox(height: 30),
                        _buildRecentShipments(),
                        const SizedBox(height: 40),
                        _buildOrderDetailsCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, size: 24, color: primaryTeal),
          const SizedBox(width: 12),
          Text(
            'Official Shipment & Order Tracker',
            style: AppTypography.headingStyle(
              context,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 24, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOOKUP BY ORDER REFERENCE ID, TRACKING NUMBER, OR CUSTOMER EMAIL:',
          style: AppTypography.bodyStyle(
            context,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _trackingController,
                  decoration: InputDecoration(
                    hintText: 'e.g. DADA-EXP-89661-101 or TRK-USPS-8966194821',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF071C21),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                'TRACK',
                style: AppTypography.bodyStyle(
                  context,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentShipments() {
    final recentShipments = [
      {'id': 'DADA-2026-89661', 'status': 'PROCESSING'},
      {'id': 'DADA-2026-89662', 'status': 'SHIPPED'},
      {'id': 'DADA-2026-89663', 'status': 'DELIVERED'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RECENT ATELIER SHIPMENTS:',
          style: AppTypography.bodyStyle(
            context,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: recentShipments.map((shipment) {
              bool isProcessing = shipment['status'] == 'PROCESSING';
              return Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isProcessing ? primaryTeal : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${shipment['id']} (${shipment['status']})',
                  style: AppTypography.bodyStyle(
                    context,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isProcessing ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'DADA-2026-89661',
                        style: AppTypography.headingStyle(context, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          'PROCESSING',
                          style: AppTypography.bodyStyle(context, fontSize: 10, fontWeight: FontWeight.w800, color: primaryTeal),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Placed on 20/02/2026 • Himanshu Rathod',
                    style: AppTypography.bodyStyle(context, fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'CARRIER & TRACKING',
                    style: AppTypography.bodyStyle(context, fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'DTDC Express',
                    style: AppTypography.bodyStyle(context, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'DTDC-IND-8966190',
                    style: AppTypography.bodyStyle(context, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildTrackingStepper(),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoBox(
                  'Shipping Destination:',
                  Icons.location_on_outlined,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Himanshu Rathod', style: AppTypography.bodyStyle(context, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('B-402, Radhe Krishna Residency, Near Temple Road Block B', style: AppTypography.bodyStyle(context, fontSize: 12, color: Colors.grey.shade700)),
                      Text('Ahmedabad, Gujarat 380015', style: AppTypography.bodyStyle(context, fontSize: 12, color: Colors.grey.shade700)),
                      Text('India', style: AppTypography.bodyStyle(context, fontSize: 12, color: Colors.grey.shade700)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildInfoBox(
                  'Shipment Items:',
                  Icons.layers_outlined,
                  Column(
                    children: [
                      _buildItemRow('2x Dada\'s Photo Keychain', '₹198.00'),
                      const SizedBox(height: 8),
                      _buildItemRow('1x Dada\'s Photo Temple (...)', '₹129.00'),
                      const SizedBox(height: 8),
                      _buildItemRow('1x Sacred Charan Paduka ...', '₹79.00'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildFooterActions(),
        ],
      ),
    );
  }

  Widget _buildItemRow(String name, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(name, style: AppTypography.bodyStyle(context, fontSize: 12, color: Colors.grey.shade700), maxLines: 1, overflow: TextOverflow.ellipsis)),
        Text(price, style: AppTypography.bodyStyle(context, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTrackingStepper() {
    return Row(
      children: [
        _stepperNode(1, 'Verified', 'Payment clear', isCompleted: true),
        _stepperConnector(isCompleted: true),
        _stepperNode(2, 'Studio Quality', 'Inspected & packed', isCurrent: true),
        _stepperConnector(isCompleted: false),
        _stepperNode(3, 'In Transit', 'Express courier'),
        _stepperConnector(isCompleted: false),
        _stepperNode(4, 'Delivered', 'Signed & received'),
      ],
    );
  }

  Widget _stepperNode(int index, String title, String subtitle, {bool isCompleted = false, bool isCurrent = false}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted || isCurrent ? const Color(0xFF071C21) : Colors.grey.shade100,
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Center(child: Text('$index', style: TextStyle(color: isCurrent ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTypography.bodyStyle(context, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTypography.bodyStyle(context, fontSize: 10, color: Colors.grey.shade500), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _stepperConnector({required bool isCompleted}) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 50),
      color: isCompleted ? const Color(0xFF071C21) : Colors.grey.shade100,
    );
  }

  Widget _buildInfoBox(String title, IconData icon, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: primaryTeal),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.bodyStyle(context, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 15),
          content,
        ],
      ),
    );
  }

  Widget _buildFooterActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              style: AppTypography.bodyStyle(context, fontSize: 14, color: Colors.grey.shade700),
              children: [
                const TextSpan(text: 'Total Paid: '),
                TextSpan(
                  text: '₹383.67',
                  style: TextStyle(fontWeight: FontWeight.w900, color: primaryTeal),
                ),
                const TextSpan(text: ' • '),
                const TextSpan(
                  text: 'UPI',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.receipt_long_outlined, size: 18, color: primaryTeal),
            label: Text('View Receipt', style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 13)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryTeal.withOpacity(0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text('Share on WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
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
