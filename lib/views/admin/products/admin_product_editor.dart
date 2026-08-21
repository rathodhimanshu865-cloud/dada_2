import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/product_controller.dart';
import '../../../models/product_model.dart';
import '../../../models/product_variant_model.dart';

class AdminProductEditor extends StatefulWidget {
  final Product? product;
  const AdminProductEditor({Key? key, this.product}) : super(key: key);

  @override
  _AdminProductEditorState createState() => _AdminProductEditorState();
}

class _AdminProductEditorState extends State<AdminProductEditor> {
  final _formKey = GlobalKey<FormState>();
  late Product _editingProduct;

  @override
  void initState() {
    super.initState();
    _editingProduct = widget.product?.copyWith() ?? Product(
      title: '',
      slug: '',
      description: '',
      price: 0,
      stockQuantity: 10,
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final controller = Provider.of<ProductController>(context, listen: false);
      if (_editingProduct.id.isEmpty) {
        controller.addProduct(_editingProduct);
      } else {
        controller.updateProduct(_editingProduct);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF0F4C5C);
    const backgroundBeige = Color(0xFFF9F3EA);
    const accentBrown = Color(0xFFC19A6B);

    return Scaffold(
      backgroundColor: backgroundBeige,
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProduct,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildSection(
              'General Information',
              [
                TextFormField(
                  initialValue: _editingProduct.title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  onSaved: (val) => _editingProduct.title = val!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _editingProduct.description,
                  decoration: const InputDecoration(labelText: 'Short Description'),
                  maxLines: 3,
                  onSaved: (val) => _editingProduct.description = val ?? '',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _editingProduct.productType,
                  decoration: const InputDecoration(labelText: 'Product Type'),
                  items: ['physical', 'digital', 'ticket', 'bundle']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase())))
                      .toList(),
                  onChanged: (val) => setState(() => _editingProduct.productType = val!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _editingProduct.author,
                  decoration: const InputDecoration(labelText: 'Author/Credit'),
                  onSaved: (val) => _editingProduct.author = val ?? 'Jignesh Dada',
                ),
              ],
            ),
            
            _buildSection(
              'Pricing',
              [
                TextFormField(
                  initialValue: _editingProduct.price?.toString() ?? '',
                  decoration: const InputDecoration(labelText: 'Regular Price (₹)'),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  onSaved: (val) => _editingProduct.price = double.tryParse(val!) ?? 0,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _editingProduct.salePrice?.toString() ?? '',
                  decoration: const InputDecoration(labelText: 'Sale Price (₹)'),
                  keyboardType: TextInputType.number,
                  onSaved: (val) => _editingProduct.salePrice = double.tryParse(val ?? ''),
                ),
              ],
            ),

            _buildSection(
              'Media (Images)',
              [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _editingProduct.images.add('');
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('ADD IMAGE URL'),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white),
                ),
                const SizedBox(height: 16),
                ..._editingProduct.images.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _editingProduct.images[index],
                            decoration: InputDecoration(labelText: 'Image URL ${index + 1}'),
                            onChanged: (val) => _editingProduct.images[index] = val,
                            onSaved: (val) => _editingProduct.images[index] = val ?? '',
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _editingProduct.images.removeAt(index);
                            });
                          },
                        )
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),

            _buildSection(
              'Inventory',
              [
                TextFormField(
                  initialValue: _editingProduct.sku,
                  decoration: const InputDecoration(labelText: 'SKU'),
                  onSaved: (val) => _editingProduct.sku = val ?? '',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _editingProduct.stockQuantity.toString(),
                  decoration: const InputDecoration(labelText: 'Stock Quantity'),
                  keyboardType: TextInputType.number,
                  onSaved: (val) => _editingProduct.stockQuantity = int.tryParse(val ?? '') ?? 0,
                ),
              ],
            ),

            _buildSection(
              'Shipping',
              [
                TextFormField(
                  initialValue: _editingProduct.weight?.toString() ?? '',
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                  onSaved: (val) => _editingProduct.weight = double.tryParse(val ?? ''),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _editingProduct.dimensions ?? '',
                  decoration: const InputDecoration(labelText: 'Dimensions (L x W x H)'),
                  onSaved: (val) => _editingProduct.dimensions = val,
                ),
              ],
            ),

            _buildSection(
              'Variants',
              [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _editingProduct.variants.add(ProductVariant(id: DateTime.now().millisecondsSinceEpoch.toString(), name: 'New Variant'));
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('ADD VARIANT'),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white),
                ),
                const SizedBox(height: 16),
                ..._editingProduct.variants.asMap().entries.map((entry) {
                  int index = entry.key;
                  final v = entry.value;
                  return Card(
                    color: Colors.grey[50],
                    child: ListTile(
                      title: Text(v.name),
                      subtitle: Text('Price: ${v.price ?? _editingProduct.price} | Stock: ${v.stockQuantity}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _editingProduct.variants.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),

            _buildSection(
              'Digital Product Settings',
              [
                SwitchListTile(
                  title: const Text('Is Digital Product?', style: TextStyle(fontWeight: FontWeight.bold)),
                  value: _editingProduct.productType == 'digital',
                  activeColor: primaryTeal,
                  onChanged: (val) => setState(() => _editingProduct.productType = val ? 'digital' : 'physical'),
                ),
                if (_editingProduct.productType == 'digital')
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: TextFormField(
                      initialValue: _editingProduct.digitalFileUrl ?? '',
                      decoration: const InputDecoration(labelText: 'Digital File URL (e.g. Firebase Storage/Drive Link)'),
                      onSaved: (val) => _editingProduct.digitalFileUrl = val,
                    ),
                  ),
              ],
            ),

            _buildSection(
              'SEO',
              [
                TextFormField(
                  initialValue: _editingProduct.metaTitle ?? '',
                  decoration: const InputDecoration(labelText: 'Meta Title'),
                  onSaved: (val) => _editingProduct.metaTitle = val,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _editingProduct.metaDescription ?? '',
                  decoration: const InputDecoration(labelText: 'Meta Description'),
                  maxLines: 3,
                  onSaved: (val) => _editingProduct.metaDescription = val,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _editingProduct.slug,
                  decoration: const InputDecoration(labelText: 'URL Slug (auto-generated if empty)'),
                  onSaved: (val) => _editingProduct.slug = val ?? '',
                ),
              ],
            ),

            _buildSection(
              'Publishing & Visibility',
              [
                SwitchListTile(
                  title: const Text('Visibility (Published/Hidden)', style: TextStyle(fontWeight: FontWeight.bold)),
                  value: _editingProduct.visible,
                  activeColor: primaryTeal,
                  onChanged: (val) => setState(() => _editingProduct.visible = val),
                ),
                SwitchListTile(
                  title: const Text('Featured Product', style: TextStyle(fontWeight: FontWeight.bold)),
                  value: _editingProduct.featured,
                  activeColor: primaryTeal,
                  onChanged: (val) => setState(() => _editingProduct.featured = val),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _editingProduct.badges.isNotEmpty ? _editingProduct.badges.first : '',
                  decoration: const InputDecoration(labelText: 'Badge (e.g. Bestseller, New, 20% OFF)'),
                  onSaved: (val) => _editingProduct.badges = (val != null && val.isNotEmpty) ? [val] : [],
                ),
              ],
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveProduct,
        backgroundColor: accentBrown,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.save),
        label: const Text('SAVE PRODUCT', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F4C5C))),
              const Divider(height: 32),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
