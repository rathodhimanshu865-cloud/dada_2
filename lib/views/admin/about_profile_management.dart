import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import '../../controllers/profile_controller.dart';
import '../../models/profile_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
const _teal   = Color(0xFF0F4C5C);
const _gold   = Color(0xFFC19A6B);
const _beige  = Color(0xFFF9F3EA);

// ─────────────────────────────────────────────────────────────────────────────
// ROOT WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class AboutProfileEditor extends StatefulWidget {
  final bool showHeader;
  const AboutProfileEditor({super.key, this.showHeader = true});

  @override
  State<AboutProfileEditor> createState() => _AboutProfileEditorState();
}

class _AboutProfileEditorState extends State<AboutProfileEditor> {
  // ── Quill (Introduction) ──────────────────────────────────────────────────
  QuillController? _quillController;
  bool _quillInitialized = false;

  // ── Local mutable copies of list sections ────────────────────────────────
  List<String> _competencies    = [];
  List<String> _highlights      = [];
  List<String> _attributes      = [];

  // ── Social Initiative text controllers ────────────────────────────────────
  final _siTitleCtrl     = TextEditingController();
  final _siVisionCtrl    = TextEditingController();
  final _siMissionCtrl   = TextEditingController();
  final _siObjectiveCtrl = TextEditingController();

  // ── Philosophy of Life ────────────────────────────────────────────────────
  final _philosophyCtrl  = TextEditingController();

  bool _isSaving       = false;
  bool _dataLoaded     = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pc = Provider.of<ProfileController>(context);
    if (!pc.isLoading && !_dataLoaded) {
      _loadFromProfile(pc.profileData);
    }
  }

  void _loadFromProfile(ProfileData? data) {
    if (data == null) return;

    // ── Quill ──
    Document doc = Document();
    if (data.contentDelta.isNotEmpty) {
      try {
        doc = Document.fromJson(jsonDecode(data.contentDelta));
      } catch (_) {}
    }
    _quillController = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    // ── Lists ──
    _competencies = List<String>.from(data.coreCompetencies);
    _highlights   = List<String>.from(data.professionalHighlights);
    _attributes   = List<String>.from(data.personalAttributes);

    // ── Social Initiative ──
    _siTitleCtrl.text     = data.socialInitiativeTitle;
    _siVisionCtrl.text    = data.socialVision;
    _siMissionCtrl.text   = data.socialMission;
    _siObjectiveCtrl.text = data.socialObjective;

    // ── Philosophy ──
    _philosophyCtrl.text  = data.philosophyOfLife;

    setState(() => _dataLoaded = true);
    _quillInitialized = true;
  }

  @override
  void dispose() {
    _quillController?.dispose();
    _siTitleCtrl.dispose();
    _siVisionCtrl.dispose();
    _siMissionCtrl.dispose();
    _siObjectiveCtrl.dispose();
    _philosophyCtrl.dispose();
    super.dispose();
  }

  // ── Save all sections ─────────────────────────────────────────────────────
  Future<void> _saveAll() async {
    setState(() => _isSaving = true);
    try {
      final pc = Provider.of<ProfileController>(context, listen: false);
      final existing = pc.profileData ?? ProfileData();

      // Build HTML from Quill
      String html  = existing.contentHTML;
      String delta = existing.contentDelta;
      if (_quillController != null) {
        final d = _quillController!.document.toDelta();
        delta = jsonEncode(d.toJson());
        html  = QuillDeltaToHtmlConverter(d.toJson(), ConverterOptions()).convert();
      }

      final updated = ProfileData(
        contentHTML:            html,
        contentDelta:           delta,
        coreCompetencies:       List<String>.from(_competencies.where((s) => s.trim().isNotEmpty)),
        professionalHighlights: List<String>.from(_highlights.where((s) => s.trim().isNotEmpty)),
        socialInitiativeTitle:  _siTitleCtrl.text.trim(),
        socialVision:           _siVisionCtrl.text.trim(),
        socialMission:          _siMissionCtrl.text.trim(),
        socialObjective:        _siObjectiveCtrl.text.trim(),
        philosophyOfLife:       _philosophyCtrl.text.trim(),
        personalAttributes:     List<String>.from(_attributes.where((s) => s.trim().isNotEmpty)),
      );

      await pc.saveProfileData(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ All profile sections saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error saving profile data'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final pc = Provider.of<ProfileController>(context);

    if (pc.isLoading || !_dataLoaded) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: _teal),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header + Save button ────────────────────────────────────────────
        if (widget.showHeader) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.05),
              border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BIOGRAPHY PAGE — ALL SECTIONS',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'IMPORTANT: You MUST click the SAVE button here to publish biography data to the live site. The global "Publish" menu does not save these sections.',
                        style: TextStyle(fontSize: 13, color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveAll,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Icon(Icons.cloud_upload_rounded, size: 24),
                  label: Text(
                    _isSaving ? 'SAVING...' : 'SAVE ALL SECTIONS NOW',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    elevation: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],

        // ── SECTION 1: Introduction ─────────────────────────────────────────
        _sectionHeader('1', 'AN INTRODUCTION', 'Rich text biography paragraph(s)'),
        const SizedBox(height: 12),
        _quillEditor(),
        const SizedBox(height: 40),

        // ── SECTION 2: Core Competencies ───────────────────────────────────
        _sectionHeader('2', 'CORE COMPETENCIES', 'Skills and areas of expertise (bullet list)'),
        const SizedBox(height: 12),
        _dynamicList(
          items: _competencies,
          hint: 'e.g. Shrimad Bhagavat Katha Exposition',
          onAdd: () => setState(() => _competencies.add('')),
          onRemove: (i) => setState(() => _competencies.removeAt(i)),
          onChanged: (i, v) => _competencies[i] = v,
        ),
        const SizedBox(height: 40),

        // ── SECTION 3: Professional Highlights ─────────────────────────────
        _sectionHeader('3', 'PROFESSIONAL HIGHLIGHTS', 'Key achievements and notable work'),
        const SizedBox(height: 12),
        _dynamicList(
          items: _highlights,
          hint: 'e.g. Delivered numerous Shrimad Bhagavat Kathas across various regions...',
          onAdd: () => setState(() => _highlights.add('')),
          onRemove: (i) => setState(() => _highlights.removeAt(i)),
          onChanged: (i, v) => _highlights[i] = v,
          multiline: true,
        ),
        const SizedBox(height: 40),

        // ── SECTION 4: Social Initiative ───────────────────────────────────
        _sectionHeader('4', 'SOCIAL INITIATIVE', 'Tathastu Vidhyapith — Vision, Mission, Objective'),
        const SizedBox(height: 12),
        _plainField(_siTitleCtrl, 'Founder Title', 'e.g. Founder – Tathastu Vidhyapith (Dream Project)'),
        const SizedBox(height: 12),
        _plainField(_siVisionCtrl, 'Vision', 'e.g. To ensure that financial limitations do not become barriers...', maxLines: 4),
        const SizedBox(height: 12),
        _plainField(_siMissionCtrl, 'Mission', 'e.g. To establish an institution that provides free academic coaching...', maxLines: 4),
        const SizedBox(height: 12),
        _plainField(_siObjectiveCtrl, 'Objective', 'e.g. To nurture young minds through education, values...', maxLines: 4),
        const SizedBox(height: 40),

        // ── SECTION 5: Philosophy of Life ──────────────────────────────────
        _sectionHeader('5', 'PHILOSOPHY OF LIFE', 'The defining quote / life motto'),
        const SizedBox(height: 12),
        _plainField(_philosophyCtrl, 'Philosophy Quote', 'e.g. Spiritual wisdom elevates the soul, while education empowers society...', maxLines: 4),
        const SizedBox(height: 40),

        // ── SECTION 6: Personal Attributes ────────────────────────────────
        _sectionHeader('6', 'PERSONAL ATTRIBUTES', 'Character traits and qualities (badge list)'),
        const SizedBox(height: 12),
        _dynamicList(
          items: _attributes,
          hint: 'e.g. Deeply Religious and Spiritually Inclined',
          onAdd: () => setState(() => _attributes.add('')),
          onRemove: (i) => setState(() => _attributes.removeAt(i)),
          onChanged: (i, v) => _attributes[i] = v,
        ),
        const SizedBox(height: 40),

        // ── Last saved timestamp ───────────────────────────────────────────
        if (pc.profileData?.lastUpdated != null)
          Text(
            'Last Saved: ${pc.profileData!.lastUpdated.toString()}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER WIDGETS
  // ─────────────────────────────────────────────────────────────────────────

  /// Numbered section header with title and subtitle
  Widget _sectionHeader(String number, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _teal,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(4)),
            alignment: Alignment.center,
            child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2)),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Quill rich-text editor for the Introduction section
  Widget _quillEditor() {
    if (_quillController == null) {
      return const Center(child: CircularProgressIndicator(color: _teal));
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          QuillSimpleToolbar(
            controller: _quillController!,
            config: const QuillSimpleToolbarConfig(
              showFontFamily: false,
              showFontSize: true,
              showBoldButton: true,
              showItalicButton: true,
              showUnderLineButton: true,
              showStrikeThrough: false,
              showColorButton: true,
              showBackgroundColorButton: false,
              showClearFormat: true,
              showLeftAlignment: true,
              showCenterAlignment: true,
              showRightAlignment: true,
              showJustifyAlignment: false,
              showHeaderStyle: true,
              showListNumbers: true,
              showListBullets: true,
              showListCheck: false,
              showCodeBlock: false,
              showQuote: true,
              showIndent: true,
              showLink: false,
              showUndo: true,
              showRedo: true,
              showDirection: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
            ),
          ),
          const Divider(height: 1),
          Container(
            height: 500,
            padding: const EdgeInsets.all(16),
            child: QuillEditor.basic(
              controller: _quillController!,
              config: const QuillEditorConfig(
                placeholder: 'Write the full introduction / biography here...',
                scrollable: true,
                expands: false,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dynamic add/remove list of text items
  Widget _dynamicList({
    required List<String> items,
    required String hint,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
    required void Function(int, String) onChanged,
    bool multiline = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _beige.withOpacity(0.4),
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            // Use TextEditingController to ensure value stays synced even if widget moves
            final controller = TextEditingController(text: items[i]);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 14, right: 10),
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: _gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text('${i + 1}', style: const TextStyle(fontSize: 11, color: _gold, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      maxLines: multiline ? 3 : 1,
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: _teal, width: 1.5),
                        ),
                      ),
                      onChanged: (v) => onChanged(i, v),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    tooltip: 'Remove item',
                    onPressed: () => onRemove(i),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('ADD ITEM'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _teal,
                side: const BorderSide(color: _teal),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Plain text field (single or multi-line)
  Widget _plainField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _teal, width: 1.5),
        ),
        labelStyle: const TextStyle(color: _teal, fontWeight: FontWeight.w600),
      ),
    );
  }
}
