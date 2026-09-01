import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/product_controller.dart';
import '../../../controllers/language_controller.dart';
import '../../../utils/app_typography.dart';

class CategoryDrawer extends StatelessWidget {
  const CategoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final prodController = Provider.of<ProductController>(context);
    final lang = Provider.of<LanguageController>(context).locale.languageCode;
    const Color primaryTeal = Color(0xFF0F4C5C);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              color: primaryTeal.withOpacity(0.05),
              child: Row(
                children: [
                  const Icon(Icons.category_outlined, color: primaryTeal),
                  const SizedBox(width: 16),
                  Text(
                    'Sacred Categories',
                    style: AppTypography.headingStyle(context, fontSize: 18, fontWeight: FontWeight.bold, color: primaryTeal),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  ListTile(
                    leading: const Icon(Icons.apps, size: 20),
                    title: const Text('All Sacred Products', style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/catalogue', arguments: 'all');
                    },
                  ),
                  const Divider(),
                  ...prodController.categoryObjects.map((cat) => ListTile(
                    leading: cat.imageUrl.isNotEmpty 
                      ? Image.network(cat.imageUrl, width: 20, height: 20, fit: BoxFit.contain)
                      : const Icon(Icons.circle, size: 8, color: Colors.grey),
                    title: Text(cat.localizedName(lang), style: const TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/catalogue', arguments: cat.id);
                    },
                  )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Center(child: Text('CLOSE')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
