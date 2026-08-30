import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dada_2/controllers/product_controller.dart';
import 'package:dada_2/models/product_model.dart';

class ProductDialogHelper {
  static void showProductDialog(BuildContext context, {ProductModel? product}) {
    final isEdit = product != null;
    final nameCtrl = TextEditingController(text: product?.name);
    final skuCtrl = TextEditingController(text: product?.sku);
    final priceCtrl = TextEditingController(text: product?.price.toString());
    final comparePriceCtrl = TextEditingController(text: product?.comparePrice?.toString() ?? '');
    final stockCtrl = TextEditingController(text: product?.stock.toString() ?? '0');
    final minStockCtrl = TextEditingController(text: product?.minStockAlert.toString() ?? '5');
    final imgUrlCtrl = TextEditingController(text: product?.imageUrl);
    final summaryCtrl = TextEditingController(text: product?.shortSummary);

    String selectedCat = product?.categoryId ?? 'keychain';
    bool isActive = product?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final prodCtrl = Provider.of<ProductController>(context, listen: false);
          return AlertDialog(
            title: Text(isEdit ? 'Edit Sacred Item' : 'Add New Sacred Item'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'PRODUCT TITLE *')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU CODE *'))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedCat,
                            decoration: const InputDecoration(labelText: 'CATEGORY *'),
                            items: prodCtrl.categoryObjects.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 12)))).toList(),
                            onChanged: (v) => setDialogState(() => selectedCat = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'SELLING PRICE *', hintText: 'Devotee pays this amount'))),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: comparePriceCtrl, decoration: const InputDecoration(labelText: 'COMPARE PRICE (MRP)', hintText: 'Original price for discount'))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'STOCK *'))),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: minStockCtrl, decoration: const InputDecoration(labelText: 'ALERT LIMIT *'))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: imgUrlCtrl, decoration: const InputDecoration(labelText: 'IMAGE URL')),
                    const SizedBox(height: 12),
                    TextField(controller: summaryCtrl, decoration: const InputDecoration(labelText: 'SHORT SUMMARY')),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final p = (isEdit ? product! : ProductModel(id: 'DADA-${DateTime.now().millisecondsSinceEpoch}', name: '', price: 0, categoryId: '')).copyWith(
                    name: nameCtrl.text,
                    sku: skuCtrl.text,
                    price: double.tryParse(priceCtrl.text) ?? 0,
                    comparePrice: double.tryParse(comparePriceCtrl.text),
                    stock: int.tryParse(stockCtrl.text) ?? 0,
                    minStockAlert: int.tryParse(minStockCtrl.text) ?? 5,
                    imageUrl: imgUrlCtrl.text,
                    shortSummary: summaryCtrl.text,
                    categoryId: selectedCat,
                    isActive: isActive,
                  );
                  if (isEdit) { await prodCtrl.updateProduct(p); } else { await prodCtrl.addProduct(p); }
                  if (context.mounted) Navigator.pop(context);
                }, 
                child: const Text('Save')
              ),
            ],
          );
        }
      ),
    );
  }
}
