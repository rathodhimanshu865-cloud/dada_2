import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import 'package:intl/intl.dart';

class ProductManagementView extends StatefulWidget {
  const ProductManagementView({super.key});

  @override
  State<ProductManagementView> createState() => _ProductManagementViewState();
}

class _ProductManagementViewState extends State<ProductManagementView> {
  final Color _primaryTeal = const Color(0xFF0F4C5C);
  bool _isAdding = false;
  Product? _editingProduct;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ProductController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('PRODUCT MANAGEMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isAdding && _editingProduct == null)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _isAdding = true),
                icon: const Icon(Icons.add),
                label: const Text('ADD NEW PRODUCT'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
              ),
            ),
        ],
      ),
      body: _isAdding || _editingProduct != null
          ? _ProductForm(
              product: _editingProduct,
              onCancel: () => setState(() {
                _isAdding = false;
                _editingProduct = null;
              }),
            )
          : _buildProductList(controller),
    );
  }

  Widget _buildProductList(ProductController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }

    if (controller.allProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No products found. Add your first product!', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: controller.allProducts.length,
      itemBuilder: (context, index) {
        final p = controller.allProducts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
                image: p.images.isNotEmpty
                    ? DecorationImage(image: NetworkImage(p.images.first), fit: BoxFit.cover)
                    : null,
              ),
              child: p.images.isEmpty ? const Icon(Icons.image_not_supported_outlined, color: Colors.grey) : null,
            ),
            title: Row(
              children: [
                Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (p.featured)
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(4)),
                    child: const Text('FEATURED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(p.price != null ? '₹${p.price}' : 'No price set', style: TextStyle(color: _primaryTeal, fontWeight: FontWeight.bold)),
                Text('/products/${p.slug}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: p.visible,
                  activeColor: _primaryTeal,
                  onChanged: (v) => controller.toggleVisibility(p.id, !v),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => setState(() => _editingProduct = p),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(context, controller, p),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ProductController controller, Product p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "${p.title}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              controller.deleteProduct(p.id);
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ProductForm extends StatefulWidget {
  final Product? product;
  final VoidCallback onCancel;

  const _ProductForm({this.product, required this.onCancel});

  @override
  State<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<_ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _slugCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _catCtrl;
  bool _featured = false;
  bool _visible = true;
  List<String> _images = [];
  bool _isSaving = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _slugCtrl = TextEditingController(text: p?.slug ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(text: p?.price?.toString() ?? '');
    _catCtrl = TextEditingController(text: p?.category ?? '');
    _featured = p?.featured ?? false;
    _visible = p?.visible ?? true;
    _images = List.from(p?.images ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _slugCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _catCtrl.dispose();
    super.dispose();
  }

  void _onTitleChanged(String val) {
    if (widget.product == null || _slugCtrl.text.isEmpty) {
      final controller = Provider.of<ProductController>(context, listen: false);
      _slugCtrl.text = controller.generateSlug(val);
    }
  }

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() => _isUploading = true);
    final controller = Provider.of<ProductController>(context, listen: false);
    
    try {
      for (var file in result.files) {
        if (file.bytes != null) {
          final url = await controller.uploadProductImage(file.name, file.bytes!);
          setState(() => _images.add(url));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final controller = Provider.of<ProductController>(context, listen: false);

    final p = Product(
      id: widget.product?.id ?? '',
      title: _titleCtrl.text,
      slug: _slugCtrl.text,
      description: _descCtrl.text,
      price: double.tryParse(_priceCtrl.text),
      category: _catCtrl.text,
      featured: _featured,
      visible: _visible,
      images: _images,
      createdAt: widget.product?.createdAt,
    );

    try {
      if (widget.product == null) {
        await controller.addProduct(p);
      } else {
        await controller.updateProduct(p);
      }
      widget.onCancel();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(onPressed: widget.onCancel, icon: const Icon(Icons.arrow_back)),
                    const SizedBox(width: 16),
                    Text(widget.product == null ? 'ADD NEW PRODUCT' : 'EDIT PRODUCT', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20)),
                      child: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('SAVE PRODUCT'),
                    ),
                  ],
                ),
                const Divider(height: 40),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _buildField('Product Title', _titleCtrl, onChanged: _onTitleChanged),
                          _buildField('URL Slug', _slugCtrl),
                          Row(
                            children: [
                              Expanded(child: _buildField('Price (₹)', _priceCtrl, keyboardType: TextInputType.number)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildField('Category', _catCtrl)),
                            ],
                          ),
                          _buildField('Description', _descCtrl, maxLines: 8),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          CheckboxListTile(
                            title: const Text('Visible on site'),
                            value: _visible,
                            onChanged: (v) => setState(() => _visible = v ?? true),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          CheckboxListTile(
                            title: const Text('Mark as Featured'),
                            value: _featured,
                            onChanged: (v) => setState(() => _featured = v ?? false),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          const SizedBox(height: 24),
                          const Text('Product Images', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 12),
                          if (_images.isEmpty)
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid)),
                              child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image_outlined, color: Colors.grey, size: 40), SizedBox(height: 8), Text('No images added', style: TextStyle(color: Colors.grey))]),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
                              itemCount: _images.length,
                              itemBuilder: (context, i) => Stack(
                                children: [
                                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(_images[i], fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
                                  Positioned(top: 4, right: 4, child: CircleAvatar(backgroundColor: Colors.white, radius: 14, child: IconButton(icon: const Icon(Icons.close, size: 14, color: Colors.red), onPressed: () => setState(() => _images.removeAt(i))))),
                                ],
                              ),
                            ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isUploading ? null : _pickImages,
                              icon: _isUploading ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload_file),
                              label: Text(_isUploading ? 'UPLOADING...' : 'UPLOAD IMAGES'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {int maxLines = 1, TextInputType? keyboardType, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
      ),
    );
  }
}
