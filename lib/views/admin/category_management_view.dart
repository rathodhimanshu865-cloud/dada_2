import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../models/category_model.dart';

class CategoryManagementView extends StatefulWidget {
  final Function(int)? onMenuChange;
  const CategoryManagementView({super.key, this.onMenuChange});

  @override
  State<CategoryManagementView> createState() => _CategoryManagementViewState();
}

class _CategoryManagementViewState extends State<CategoryManagementView> {
  @override
  Widget build(BuildContext context) {
    final productController = Provider.of<ProductController>(context);
    
    final categories = productController.categoryObjects;

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
                  const Text('Category Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Organize Pu. Dada sacred offerings into distinct store categories.', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showCategoryDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('ADD NEW CATEGORY', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
          
          categories.isEmpty 
            ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('No categories found.')))
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final cat = categories[i];
                  // Count products in this category
                  final count = productController.allProducts.where((p) => p.categoryId.toLowerCase().trim() == cat.id.toLowerCase().trim()).length;
                  
                  return _buildCategoryCard(context, cat, count, productController);
                },
              ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryModel cat, int productCount, ProductController prodCtrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                child: cat.imageUrl.startsWith('http') 
                  ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(cat.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.category_outlined, color: Colors.amber)))
                  : const Icon(Icons.category_outlined, color: Colors.amber),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
                child: Text('$productCount Products', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(cat.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              cat.description, 
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  prodCtrl.selectCategory(cat.id);
                  widget.onMenuChange?.call(1);
                }, 
                child: const Text('View Products →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber))
              ),
              Row(
                children: [
                  IconButton(onPressed: () => _showCategoryDialog(context, category: cat), icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey)),
                  IconButton(
                    onPressed: () => _confirmDelete(context, cat, prodCtrl), 
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey)
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {CategoryModel? category}) {
    final isEdit = category != null;
    final nameCtrl = TextEditingController(text: category?.name);
    final descCtrl = TextEditingController(text: category?.description);
    final imgCtrl = TextEditingController(text: category?.imageUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Category' : 'Add New Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Category Name')),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 12),
            TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'Image URL')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final prodCtrl = Provider.of<ProductController>(context, listen: false);
              final newCat = CategoryModel(
                id: isEdit ? category.id : nameCtrl.text.toLowerCase().replaceAll(' ', '_'),
                name: nameCtrl.text,
                description: descCtrl.text,
                imageUrl: imgCtrl.text,
              );
              if (isEdit) {
                await prodCtrl.updateCategory(newCat);
              } else {
                await prodCtrl.addCategory(newCat);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, CategoryModel cat, ProductController prodCtrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text('Are you sure you want to delete "${cat.name}"? This will not delete products in this category but they will be unassigned.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await prodCtrl.deleteCategory(cat.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

