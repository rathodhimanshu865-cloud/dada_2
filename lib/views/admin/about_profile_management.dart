import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import '../../controllers/profile_controller.dart';
import '../../models/profile_model.dart';
import '../../services/translation_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
const _teal   = Color(0xFF0F4C5C);
const _gold   = Color(0xFFC19A6B);
const _beige  = Color(0xFFF9F3EA);

class _LanguageFormState {
  QuillController? quillController;
  List<String> competencies = [];
  List<String> highlights = [];
  List<String> attributes = [];
  final siTitleCtrl = TextEditingController();
  final siVisionCtrl = TextEditingController();
  final siMissionCtrl = TextEditingController();
  final siObjectiveCtrl = TextEditingController();
  final philosophyCtrl = TextEditingController();
  final sigTitleCtrl = TextEditingController();
  final sigSubtitleCtrl = TextEditingController();

  void dispose() {
    quillController?.dispose();
    siTitleCtrl.dispose();
    siVisionCtrl.dispose();
    siMissionCtrl.dispose();
    siObjectiveCtrl.dispose();
    philosophyCtrl.dispose();
    sigTitleCtrl.dispose();
    sigSubtitleCtrl.dispose();
  }
}

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
  final Map<String, _LanguageFormState> _forms = {
    'en': _LanguageFormState(),
    'hi': _LanguageFormState(),
    'gu': _LanguageFormState(),
  };

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

  void _loadLanguage(String lang, String deltaStr, List<String> comp, List<String> high, List<String> attr, String siTitle, String siVis, String siMiss, String siObj, String phil, String sigTitle, String sigSub) {
    final form = _forms[lang]!;
    Document doc = Document();
    if (deltaStr.isNotEmpty) {
      try { doc = Document.fromJson(jsonDecode(deltaStr)); } catch (_) {}
    }
    form.quillController = QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));
    form.competencies = List<String>.from(comp);
    form.highlights = List<String>.from(high);
    form.attributes = List<String>.from(attr);
    form.siTitleCtrl.text = siTitle;
    form.siVisionCtrl.text = siVis;
    form.siMissionCtrl.text = siMiss;
    form.siObjectiveCtrl.text = siObj;
    form.philosophyCtrl.text = phil;
    form.sigTitleCtrl.text = sigTitle;
    form.sigSubtitleCtrl.text = sigSub;
  }

  Future<void> _loadFromProfile(ProfileData? data) async {
    if (data == null) return;
    
    // Yield the thread to allow navigation animation and loading spinner to paint
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    _loadLanguage('en', data.contentDelta, data.coreCompetencies, data.professionalHighlights, data.personalAttributes, data.socialInitiativeTitle, data.socialVision, data.socialMission, data.socialObjective, data.philosophyOfLife, data.signatureIdentityTitle, data.signatureIdentitySubtitle);
    
    await Future.delayed(const Duration(milliseconds: 10)); // Yield again
    if (!mounted) return;
    
    _loadLanguage('hi', data.contentDeltaHi, data.coreCompetenciesHi, data.professionalHighlightsHi, data.personalAttributesHi, data.socialInitiativeTitleHi, data.socialVisionHi, data.socialMissionHi, data.socialObjectiveHi, data.philosophyOfLifeHi, data.signatureIdentityTitleHi, data.signatureIdentitySubtitleHi);
    
    await Future.delayed(const Duration(milliseconds: 10)); // Yield again
    if (!mounted) return;
    
    _loadLanguage('gu', data.contentDeltaGu, data.coreCompetenciesGu, data.professionalHighlightsGu, data.personalAttributesGu, data.socialInitiativeTitleGu, data.socialVisionGu, data.socialMissionGu, data.socialObjectiveGu, data.philosophyOfLifeGu, data.signatureIdentityTitleGu, data.signatureIdentitySubtitleGu);
    
    if (mounted) setState(() => _dataLoaded = true);
  }

  @override
  void dispose() {
    for (var f in _forms.values) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAll() async {
    setState(() => _isSaving = true);
    try {
      final pc = Provider.of<ProfileController>(context, listen: false);

      String getHtml(QuillController? qc) {
        if (qc == null) return '';
        try {
          return QuillDeltaToHtmlConverter(qc.document.toDelta().toJson(), ConverterOptions()).convert();
        } catch (_) { return ''; }
      }
      String getDelta(QuillController? qc) {
        if (qc == null) return '';
        return jsonEncode(qc.document.toDelta().toJson());
      }

      final fEn = _forms['en']!;
      final fHi = _forms['hi']!;
      final fGu = _forms['gu']!;

      final updated = ProfileData(
        contentHTML: getHtml(fEn.quillController),
        contentDelta: getDelta(fEn.quillController),
        contentHTMLHi: getHtml(fHi.quillController),
        contentDeltaHi: getDelta(fHi.quillController),
        contentHTMLGu: getHtml(fGu.quillController),
        contentDeltaGu: getDelta(fGu.quillController),
        
        coreCompetencies: List<String>.from(fEn.competencies.where((s) => s.trim().isNotEmpty)),
        coreCompetenciesHi: List<String>.from(fHi.competencies.where((s) => s.trim().isNotEmpty)),
        coreCompetenciesGu: List<String>.from(fGu.competencies.where((s) => s.trim().isNotEmpty)),
        
        professionalHighlights: List<String>.from(fEn.highlights.where((s) => s.trim().isNotEmpty)),
        professionalHighlightsHi: List<String>.from(fHi.highlights.where((s) => s.trim().isNotEmpty)),
        professionalHighlightsGu: List<String>.from(fGu.highlights.where((s) => s.trim().isNotEmpty)),
        
        socialInitiativeTitle: fEn.siTitleCtrl.text.trim(),
        socialInitiativeTitleHi: fHi.siTitleCtrl.text.trim(),
        socialInitiativeTitleGu: fGu.siTitleCtrl.text.trim(),
        
        socialVision: fEn.siVisionCtrl.text.trim(),
        socialVisionHi: fHi.siVisionCtrl.text.trim(),
        socialVisionGu: fGu.siVisionCtrl.text.trim(),
        
        socialMission: fEn.siMissionCtrl.text.trim(),
        socialMissionHi: fHi.siMissionCtrl.text.trim(),
        socialMissionGu: fGu.siMissionCtrl.text.trim(),
        
        socialObjective: fEn.siObjectiveCtrl.text.trim(),
        socialObjectiveHi: fHi.siObjectiveCtrl.text.trim(),
        socialObjectiveGu: fGu.siObjectiveCtrl.text.trim(),
        
        philosophyOfLife: fEn.philosophyCtrl.text.trim(),
        philosophyOfLifeHi: fHi.philosophyCtrl.text.trim(),
        philosophyOfLifeGu: fGu.philosophyCtrl.text.trim(),
        
        personalAttributes: List<String>.from(fEn.attributes.where((s) => s.trim().isNotEmpty)),
        personalAttributesHi: List<String>.from(fHi.attributes.where((s) => s.trim().isNotEmpty)),
        personalAttributesGu: List<String>.from(fGu.attributes.where((s) => s.trim().isNotEmpty)),
        
        signatureIdentityTitle: fEn.sigTitleCtrl.text.trim(),
        signatureIdentityTitleHi: fHi.sigTitleCtrl.text.trim(),
        signatureIdentityTitleGu: fGu.sigTitleCtrl.text.trim(),
        
        signatureIdentitySubtitle: fEn.sigSubtitleCtrl.text.trim(),
        signatureIdentitySubtitleHi: fHi.sigSubtitleCtrl.text.trim(),
        signatureIdentitySubtitleGu: fGu.sigSubtitleCtrl.text.trim(),
      );

      await pc.saveProfileData(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All profile sections saved successfully! (EN, HI, GU)'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_dataLoaded) return const Center(child: CircularProgressIndicator(color: _teal));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: Column(
          children: [
            if (widget.showHeader) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 16,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About Dada Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _teal)),
                        SizedBox(height: 4),
                        Text('Manage the massive biography & structured sections.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveAll,
                          icon: _isSaving
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.save, size: 18),
                          label: const Text('Save All Sections'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _teal, foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: _teal,
                unselectedLabelColor: Colors.grey,
                indicatorColor: _gold,
                indicatorWeight: 4,
                tabs: [
                  Tab(text: 'English'),
                  Tab(text: 'Hindi (हिन्दी)'),
                  Tab(text: 'Gujarati (ગુજરાતી)'),
                ],
              ),
            ),
            
            Expanded(
              child: TabBarView(
                children: [
                  _buildFormTab('en', _forms['en']!),
                  _buildFormTab('hi', _forms['hi']!),
                  _buildFormTab('gu', _forms['gu']!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTab(String lang, _LanguageFormState formState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('01', 'INTRODUCTION / BIOGRAPHY', 'The main long-form text with rich formatting (Quill).'),
              const SizedBox(height: 16),
              _quillEditor(formState.quillController),
              const SizedBox(height: 48),

              _sectionHeader('02', 'CORE COMPETENCIES', 'Short bullet points describing key skills or domains.'),
              const SizedBox(height: 16),
              _dynamicList(
                items: formState.competencies,
                hint: 'e.g. Shrimad Bhagavat Katha Exposition',
                onAdd: () => setState(() => formState.competencies.add('')),
                onRemove: (i) => setState(() => formState.competencies.removeAt(i)),
                onChanged: (i, v) => formState.competencies[i] = v,
              ),
              const SizedBox(height: 48),

              _sectionHeader('03', 'PROFESSIONAL HIGHLIGHTS', 'Notable achievements, global reach, or major milestones.'),
              const SizedBox(height: 16),
              _dynamicList(
                items: formState.highlights,
                hint: 'e.g. Conducted over 500 kathas globally...',
                onAdd: () => setState(() => formState.highlights.add('')),
                onRemove: (i) => setState(() => formState.highlights.removeAt(i)),
                onChanged: (i, v) => formState.highlights[i] = v,
                multiline: true,
              ),
              const SizedBox(height: 48),

              _sectionHeader('04', 'SOCIAL INITIATIVE & VISION', 'Details about humanitarian work and goals.'),
              const SizedBox(height: 16),
              _plainField(formState.siTitleCtrl, 'Initiative Title', 'e.g. Humanitarian & Social Initiatives'),
              const SizedBox(height: 16),
              _plainField(formState.siVisionCtrl, 'Vision', 'Describe the overarching vision...', maxLines: 4),
              const SizedBox(height: 16),
              _plainField(formState.siMissionCtrl, 'Mission', 'Describe the mission...', maxLines: 4),
              const SizedBox(height: 16),
              _plainField(formState.siObjectiveCtrl, 'Objective', 'Describe the specific objectives...', maxLines: 4),
              const SizedBox(height: 48),

              _sectionHeader('05', 'PHILOSOPHY OF LIFE', 'A core quote or guiding principle.'),
              const SizedBox(height: 16),
              _plainField(formState.philosophyCtrl, 'Philosophy', 'e.g. "True devotion is not just in prayer..."', maxLines: 4),
              const SizedBox(height: 48),

              _sectionHeader('06', 'PERSONAL ATTRIBUTES', 'Qualities that define the persona.'),
              const SizedBox(height: 16),
              _dynamicList(
                items: formState.attributes,
                hint: 'e.g. Humility and Compassion',
                onAdd: () => setState(() => formState.attributes.add('')),
                onRemove: (i) => setState(() => formState.attributes.removeAt(i)),
                onChanged: (i, v) => formState.attributes[i] = v,
              ),
              const SizedBox(height: 48),

              _sectionHeader('07', 'SIGNATURE IDENTITY', 'The custom mantra and subtitle displayed at the bottom.'),
              const SizedBox(height: 16),
              _plainField(formState.sigTitleCtrl, 'Title (e.g. "Radhe Radhe")', 'Enter the signature phrase'),
              const SizedBox(height: 16),
              _plainField(formState.sigSubtitleCtrl, 'Subtitle', 'e.g. The profound mantra...'),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String number, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: _teal, borderRadius: BorderRadius.circular(8)),
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

  Widget _quillEditor(QuillController? qc) {
    if (qc == null) return const Center(child: CircularProgressIndicator(color: _teal));
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          QuillSimpleToolbar(
            controller: qc,
            config: const QuillSimpleToolbarConfig(
              showFontFamily: false, showFontSize: true, showBoldButton: true,
              showItalicButton: true, showUnderLineButton: true, showStrikeThrough: false,
              showColorButton: true, showBackgroundColorButton: false, showClearFormat: true,
              showLeftAlignment: true, showCenterAlignment: true, showRightAlignment: true,
              showJustifyAlignment: false, showHeaderStyle: true, showListNumbers: true,
              showListBullets: true, showListCheck: false, showCodeBlock: false,
              showQuote: true, showIndent: true, showLink: false, showUndo: true, showRedo: true,
              showDirection: false, showSearchButton: false, showSubscript: false, showSuperscript: false,
            ),
          ),
          const Divider(height: 1),
          Container(
            height: 500, padding: const EdgeInsets.all(16),
            child: QuillEditor.basic(
              controller: qc,
              config: const QuillEditorConfig(
                placeholder: 'Write here...', scrollable: true, expands: false, padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dynamicList({required List<String> items, required String hint, required VoidCallback onAdd, required void Function(int) onRemove, required void Function(int, String) onChanged, bool multiline = false}) {
    return Container(
      decoration: BoxDecoration(color: _beige.withOpacity(0.4), border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final controller = TextEditingController(text: items[i]);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 14, right: 10),
                    width: 24, height: 24, decoration: BoxDecoration(color: _gold.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                    alignment: Alignment.center, child: Text('${i + 1}', style: const TextStyle(fontSize: 11, color: _gold, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: controller, maxLines: multiline ? 3 : 1,
                      decoration: InputDecoration(
                        hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13), filled: true, fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: _teal, width: 1.5)),
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
