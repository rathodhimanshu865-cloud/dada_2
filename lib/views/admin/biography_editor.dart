import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_quill/quill_delta.dart' as qd;
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'dart:convert';
import '../../controllers/profile_controller.dart';
import '../../services/translation_service.dart';
import '../../controllers/homepage_controller.dart';

class BiographyEditor extends StatefulWidget {
  const BiographyEditor({super.key});

  @override
  State<BiographyEditor> createState() => _BiographyEditorState();
}

class _BiographyEditorState extends State<BiographyEditor> {
  late QuillController _introController;
  
  // Track individual field loading states for inline translation animation
  final Map<String, bool> _fieldLoading = {};

  @override
  void initState() {
    super.initState();
    _introController = QuillController.basic();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  void _loadInitialData() {
    final p = Provider.of<ProfileController>(context, listen: false).profileData;
    if (p != null && p.contentDelta.isNotEmpty) {
      try {
        final dynamic deltaJson = jsonDecode(p.contentDelta);
        _introController.document = Document.fromDelta(qd.Delta.fromJson(deltaJson));
      } catch (e) {
        final delta = HtmlToDelta().convert(p.contentHTML);
        _introController.document = Document.fromDelta(delta);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prof = Provider.of<ProfileController>(context);
    final home = Provider.of<HomePageController>(context);
    final p = prof.profileData;

    if (p == null) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        _buildSectionHeader('FULL BIOGRAPHY EDITOR', 'Update every detail displayed on the user-side About page'),
        
        // 1. Introduction
        _buildCard(
          title: '1. INTRODUCTION (Rich Text)',
          child: Column(
            children: [
              _buildImageField('Biography Hero Image', home.aboutDadaPage.heroImage, (v) => setState(() => home.aboutDadaPage.heroImage = v)),
              const SizedBox(height: 20),
              // Use specific widget based on current flutter_quill version (likely 10.0+)
              const Text("Rich Text Introduction Editor", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                height: 400,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                padding: const EdgeInsets.all(12),
                child: QuillEditor.basic(
                  controller: _introController,
                ),
              ),
            ],
          ),
        ),

        // 2. Core Competencies
        _buildListCard(
          title: '2. CORE COMPETENCIES',
          items: p.coreCompetencies,
          onAdd: () => setState(() => p.coreCompetencies.add('')),
          onRemove: (i) => setState(() => p.coreCompetencies.removeAt(i)),
          onChanged: (i, v) => p.coreCompetencies[i] = v,
          translateKey: 'comp',
        ),

        // 3. Professional Highlights
        _buildListCard(
          title: '3. PROFESSIONAL HIGHLIGHTS',
          items: p.professionalHighlights,
          onAdd: () => setState(() => p.professionalHighlights.add('')),
          onRemove: (i) => setState(() => p.professionalHighlights.removeAt(i)),
          onChanged: (i, v) => p.professionalHighlights[i] = v,
          translateKey: 'highlights',
        ),

        // 4. Social Initiative
        _buildCard(
          title: '4. SOCIAL INITIATIVE',
          child: Column(
            children: [
              _buildField('Section Title', p.socialInitiativeTitle, (v) => p.socialInitiativeTitle = v, 'social_title'),
              _buildField('Vision', p.socialVision, (v) => p.socialVision = v, 'social_vision'),
              _buildField('Mission', p.socialMission, (v) => p.socialMission = v, 'social_mission'),
              _buildField('Objective', p.socialObjective, (v) => p.socialObjective = v, 'social_obj'),
            ],
          ),
        ),

        // 5. Philosophy
        _buildCard(
          title: '5. PHILOSOPHY OF LIFE',
          child: _buildField('Quote', p.philosophyOfLife, (v) => p.philosophyOfLife = v, 'phil', maxLines: 3),
        ),

        // 6. Personal Attributes
        _buildListCard(
          title: '6. PERSONAL ATTRIBUTES',
          items: p.personalAttributes,
          onAdd: () => setState(() => p.personalAttributes.add('')),
          onRemove: (i) => setState(() => p.personalAttributes.removeAt(i)),
          onChanged: (i, v) => p.personalAttributes[i] = v,
          translateKey: 'attr',
        ),

        // 7. Signature Identity
        _buildCard(
          title: '7. SIGNATURE IDENTITY',
          child: Column(
            children: [
              _buildField('Bold Title (Purple)', p.signatureIdentityTitle, (v) => p.signatureIdentityTitle = v, 'sig_title'),
              _buildField('Italic Subtitle (Red)', p.signatureIdentitySubtitle, (v) => p.signatureIdentitySubtitle = v, 'sig_sub'),
            ],
          ),
        ),

        const SizedBox(height: 50),
        
        SizedBox(
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () async {
              final delta = _introController.document.toDelta();
              final html = QuillDeltaToHtmlConverter(delta.toJson()).convert();
              p.contentHTML = html;
              p.contentDelta = jsonEncode(delta.toJson());
              
              await Future.wait([
                prof.saveProfileData(p),
                home.publish(),
              ]);
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biography Updated Successfully!')));
            },
            icon: const Icon(Icons.cloud_done),
            label: const Text('PUBLISH ALL CHANGES TO LIVE SITE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F4C5C))),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const Divider(height: 32, thickness: 2),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value, Function(String) onChanged, String transKey, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: value)..selection = TextSelection.collapsed(offset: value.length),
            onChanged: onChanged,
            maxLines: maxLines,
            decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required List<String> items,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    required Function(int, String) onChanged,
    required String translateKey,
  }) {
    return _buildCard(
      title: title,
      child: Column(
        children: [
          ...items.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: e.value)..selection = TextSelection.collapsed(offset: e.value.length),
                    onChanged: (v) => onChanged(e.key, v),
                    decoration: InputDecoration(isDense: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ),
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => onRemove(e.key)),
              ],
            ),
          )),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add Item')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageField(String label, String currentUrl, Function(String) onUploaded) {
    final TextEditingController linkController = TextEditingController(text: currentUrl);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool useVertical = constraints.maxWidth < 600;
        
        Widget imageWidget = currentUrl.isNotEmpty 
          ? Image.network(
              currentUrl, 
              width: 100, 
              height: 100, 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100, 
                height: 100, 
                color: Colors.grey.shade100,
                child: const Icon(Icons.broken_image_outlined, color: Colors.grey, size: 32),
              ),
            )
          : Container(
              width: 100, 
              height: 100, 
              color: Colors.grey.shade100,
              child: const Icon(Icons.image_outlined, color: Colors.grey, size: 32),
            );

        return Card(
          margin: const EdgeInsets.only(bottom: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F4C5C))),
                const SizedBox(height: 16),
                if (useVertical) ...[
                  Center(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: imageWidget)),
                  const SizedBox(height: 20),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!useVertical) ...[
                      ClipRRect(borderRadius: BorderRadius.circular(12), child: imageWidget),
                      const SizedBox(width: 24),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Paste Image URL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: linkController,
                            onChanged: onUploaded,
                            decoration: InputDecoration(
                              hintText: 'https://example.com/image.jpg',
                              isDense: true,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('OR Upload from PC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final url = await Provider.of<HomePageController>(context, listen: false).uploadPhotoFromFile();
                              if (url != null) onUploaded(url);
                            },
                            icon: const Icon(Icons.computer, size: 18),
                            label: const Text('SELECT FROM PC'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        );
      }
    );
  }
}
