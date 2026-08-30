import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';

class InventoryStockView extends StatelessWidget {
  const InventoryStockView({super.key});

  @override
  Widget build(BuildContext context) {
    final prodCtrl = Provider.of<ProductController>(context);

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
                  const Text('Inventory & Stock Replenishment', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Monitor real-time warehouse levels and trigger batch restocks.', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
              _buildSafetyIndicator(prodCtrl),
            ],
          ),
          const SizedBox(height: 32),
          
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              children: [
                _buildTableHeader(),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: prodCtrl.allProducts.length,
                  separatorBuilder: (context, i) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = prodCtrl.allProducts[i];
                    return _buildInventoryRow(context, p, prodCtrl);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyIndicator(ProductController prodCtrl) {
    final lowStockCount = prodCtrl.allProducts.where((p) => p.stock <= p.minStockAlert).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Text('$lowStockCount items below safety threshold', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber)),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.grey.shade50,
      child: const Row(
        children: [
          Expanded(flex: 4, child: Text('ITEM & SKU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text('CURRENT STOCK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text('SAFETY LIMIT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text('STATUS INDICATOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text('BATCH REPLENISH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildInventoryRow(BuildContext context, ProductModel p, ProductController prodCtrl) {
    bool isLow = p.stock <= p.minStockAlert;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 800;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(p.sku, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Text('${p.stock}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isLow ? Colors.red : Colors.black87)),
              ),
              if (isWide)
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: isLow ? Colors.red.shade50 : Colors.teal.shade50, borderRadius: BorderRadius.circular(4)),
                    child: Text(isLow ? 'LOW' : 'OK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isLow ? Colors.red : Colors.teal), textAlign: TextAlign.center),
                  ),
                ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _replenishBtn(context, '+5', () => prodCtrl.updateProduct(p.copyWith(stock: p.stock + 5))),
                    const SizedBox(width: 4),
                    _replenishBtn(context, '+25', () => prodCtrl.updateProduct(p.copyWith(stock: p.stock + 25)), isPrimary: true),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _replenishBtn(BuildContext context, String label, VoidCallback onTap, {bool isPrimary = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF8B4513) : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isPrimary ? const Color(0xFF8B4513) : Colors.grey.shade300),
        ),
        child: Text(
          label, 
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isPrimary ? Colors.white : Colors.black87)
        ),
      ),
    );
  }
}
