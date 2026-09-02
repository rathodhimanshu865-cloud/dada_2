import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dada_2/l10n/app_localizations.dart';
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
                  Text(AppLocalizations.of(context)!.inventoryStockReplenishment, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context)!.monitorWarehouseLevels, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
              _buildSafetyIndicator(context, prodCtrl),
            ],
          ),
          const SizedBox(height: 32),
          
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              children: [
                _buildTableHeader(context),
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

  Widget _buildSafetyIndicator(BuildContext context, ProductController prodCtrl) {
    final lowStockCount = prodCtrl.allProducts.where((p) => p.stock <= p.minStockAlert).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.lowStockItemsBelow(lowStockCount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber)),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(AppLocalizations.of(context)!.itemSku, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text(AppLocalizations.of(context)!.currentStock, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text(AppLocalizations.of(context)!.safetyLimit, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text(AppLocalizations.of(context)!.statusIndicator, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(flex: 2, child: Text(AppLocalizations.of(context)!.batchReplenish, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
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
                child: Row(
                  children: [
                    Text('${p.stock}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isLow ? Colors.red : Colors.black87)),
                    if (p.stock <= 2) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                        child: Text(AppLocalizations.of(context)!.outOfStockBadge, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
              ),
              if (isWide)
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: isLow ? Colors.red.shade50 : Colors.teal.shade50, borderRadius: BorderRadius.circular(4)),
                    child: Text(isLow ? AppLocalizations.of(context)!.lowBadge : AppLocalizations.of(context)!.okBadge, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isLow ? Colors.red : Colors.teal), textAlign: TextAlign.center),
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
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 16, color: Colors.grey),
                      onPressed: () => _showManualStockDialog(context, p, prodCtrl),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  void _showManualStockDialog(BuildContext context, ProductModel p, ProductController prodCtrl) {
    final TextEditingController stockCtrl = TextEditingController(text: p.stock.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.manualStockUpdate(p.name)),
        content: TextField(
          controller: stockCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.setAbsoluteStock),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(stockCtrl.text) ?? p.stock;
              prodCtrl.updateProduct(p.copyWith(stock: newStock));
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.update),
          ),
        ],
      ),
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
