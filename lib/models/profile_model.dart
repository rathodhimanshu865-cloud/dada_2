import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileData {
  // ── Introduction (Quill rich text) ──────────────────────────────────────────
  String contentHTML;
  String contentDelta;
  String contentHTMLHi;
  String contentDeltaHi;
  String contentHTMLGu;
  String contentDeltaGu;

  // ── Structured sections ──────────────────────────────────────────────────────
  List<String> coreCompetencies;
  List<String> coreCompetenciesHi;
  List<String> coreCompetenciesGu;

  List<String> professionalHighlights;
  List<String> professionalHighlightsHi;
  List<String> professionalHighlightsGu;

  // Social Initiative
  String socialInitiativeTitle;
  String socialInitiativeTitleHi;
  String socialInitiativeTitleGu;
  
  String socialVision;
  String socialVisionHi;
  String socialVisionGu;
  
  String socialMission;
  String socialMissionHi;
  String socialMissionGu;
  
  String socialObjective;
  String socialObjectiveHi;
  String socialObjectiveGu;

  // Philosophy of Life
  String philosophyOfLife;
  String philosophyOfLifeHi;
  String philosophyOfLifeGu;

  // Personal Attributes
  List<String> personalAttributes;
  List<String> personalAttributesHi;
  List<String> personalAttributesGu;

  // Signature Identity
  String signatureIdentityTitle;
  String signatureIdentityTitleHi;
  String signatureIdentityTitleGu;
  
  String signatureIdentitySubtitle;
  String signatureIdentitySubtitleHi;
  String signatureIdentitySubtitleGu;

  DateTime? lastUpdated;

  ProfileData({
    this.contentHTML = '',
    this.contentDelta = '',
    this.contentHTMLHi = '',
    this.contentDeltaHi = '',
    this.contentHTMLGu = '',
    this.contentDeltaGu = '',
    List<String>? coreCompetencies,
    List<String>? coreCompetenciesHi,
    List<String>? coreCompetenciesGu,
    List<String>? professionalHighlights,
    List<String>? professionalHighlightsHi,
    List<String>? professionalHighlightsGu,
    this.socialInitiativeTitle = '',
    this.socialInitiativeTitleHi = '',
    this.socialInitiativeTitleGu = '',
    this.socialVision = '',
    this.socialVisionHi = '',
    this.socialVisionGu = '',
    this.socialMission = '',
    this.socialMissionHi = '',
    this.socialMissionGu = '',
    this.socialObjective = '',
    this.socialObjectiveHi = '',
    this.socialObjectiveGu = '',
    this.philosophyOfLife = '',
    this.philosophyOfLifeHi = '',
    this.philosophyOfLifeGu = '',
    List<String>? personalAttributes,
    List<String>? personalAttributesHi,
    List<String>? personalAttributesGu,
    this.signatureIdentityTitle = '',
    this.signatureIdentityTitleHi = '',
    this.signatureIdentityTitleGu = '',
    this.signatureIdentitySubtitle = '',
    this.signatureIdentitySubtitleHi = '',
    this.signatureIdentitySubtitleGu = '',
    this.lastUpdated,
  })  : coreCompetencies = coreCompetencies ?? [],
        coreCompetenciesHi = coreCompetenciesHi ?? [],
        coreCompetenciesGu = coreCompetenciesGu ?? [],
        professionalHighlights = professionalHighlights ?? [],
        professionalHighlightsHi = professionalHighlightsHi ?? [],
        professionalHighlightsGu = professionalHighlightsGu ?? [],
        personalAttributes = personalAttributes ?? [],
        personalAttributesHi = personalAttributesHi ?? [],
        personalAttributesGu = personalAttributesGu ?? [];

  // Localized Getters
  String localizedContentHTML(String lang) => lang == 'hi' && contentHTMLHi.isNotEmpty ? contentHTMLHi : lang == 'gu' && contentHTMLGu.isNotEmpty ? contentHTMLGu : contentHTML;
  List<String> localizedCoreCompetencies(String lang) => lang == 'hi' && coreCompetenciesHi.isNotEmpty ? coreCompetenciesHi : lang == 'gu' && coreCompetenciesGu.isNotEmpty ? coreCompetenciesGu : coreCompetencies;
  List<String> localizedProfessionalHighlights(String lang) => lang == 'hi' && professionalHighlightsHi.isNotEmpty ? professionalHighlightsHi : lang == 'gu' && professionalHighlightsGu.isNotEmpty ? professionalHighlightsGu : professionalHighlights;
  
  String localizedSocialTitle(String lang) => lang == 'hi' && socialInitiativeTitleHi.isNotEmpty ? socialInitiativeTitleHi : lang == 'gu' && socialInitiativeTitleGu.isNotEmpty ? socialInitiativeTitleGu : socialInitiativeTitle;
  String localizedSocialVision(String lang) => lang == 'hi' && socialVisionHi.isNotEmpty ? socialVisionHi : lang == 'gu' && socialVisionGu.isNotEmpty ? socialVisionGu : socialVision;
  String localizedSocialMission(String lang) => lang == 'hi' && socialMissionHi.isNotEmpty ? socialMissionHi : lang == 'gu' && socialMissionGu.isNotEmpty ? socialMissionGu : socialMission;
  String localizedSocialObjective(String lang) => lang == 'hi' && socialObjectiveHi.isNotEmpty ? socialObjectiveHi : lang == 'gu' && socialObjectiveGu.isNotEmpty ? socialObjectiveGu : socialObjective;
  
  String localizedPhilosophy(String lang) => lang == 'hi' && philosophyOfLifeHi.isNotEmpty ? philosophyOfLifeHi : lang == 'gu' && philosophyOfLifeGu.isNotEmpty ? philosophyOfLifeGu : philosophyOfLife;
  List<String> localizedPersonalAttributes(String lang) => lang == 'hi' && personalAttributesHi.isNotEmpty ? personalAttributesHi : lang == 'gu' && personalAttributesGu.isNotEmpty ? personalAttributesGu : personalAttributes;
  
  String localizedSignatureTitle(String lang) => lang == 'hi' && signatureIdentityTitleHi.isNotEmpty ? signatureIdentityTitleHi : lang == 'gu' && signatureIdentityTitleGu.isNotEmpty ? signatureIdentityTitleGu : signatureIdentityTitle;
  String localizedSignatureSubtitle(String lang) => lang == 'hi' && signatureIdentitySubtitleHi.isNotEmpty ? signatureIdentitySubtitleHi : lang == 'gu' && signatureIdentitySubtitleGu.isNotEmpty ? signatureIdentitySubtitleGu : signatureIdentitySubtitle;

  Map<String, dynamic> toMap() {
    return {
      'contentHTML': contentHTML,
      'contentDelta': contentDelta,
      'contentHTML_hi': contentHTMLHi,
      'contentDelta_hi': contentDeltaHi,
      'contentHTML_gu': contentHTMLGu,
      'contentDelta_gu': contentDeltaGu,
      
      'coreCompetencies': coreCompetencies,
      'coreCompetencies_hi': coreCompetenciesHi,
      'coreCompetencies_gu': coreCompetenciesGu,
      
      'professionalHighlights': professionalHighlights,
      'professionalHighlights_hi': professionalHighlightsHi,
      'professionalHighlights_gu': professionalHighlightsGu,
      
      'socialInitiativeTitle': socialInitiativeTitle,
      'socialInitiativeTitle_hi': socialInitiativeTitleHi,
      'socialInitiativeTitle_gu': socialInitiativeTitleGu,
      
      'socialVision': socialVision,
      'socialVision_hi': socialVisionHi,
      'socialVision_gu': socialVisionGu,
      
      'socialMission': socialMission,
      'socialMission_hi': socialMissionHi,
      'socialMission_gu': socialMissionGu,
      
      'socialObjective': socialObjective,
      'socialObjective_hi': socialObjectiveHi,
      'socialObjective_gu': socialObjectiveGu,
      
      'philosophyOfLife': philosophyOfLife,
      'philosophyOfLife_hi': philosophyOfLifeHi,
      'philosophyOfLife_gu': philosophyOfLifeGu,
      
      'personalAttributes': personalAttributes,
      'personalAttributes_hi': personalAttributesHi,
      'personalAttributes_gu': personalAttributesGu,
      
      'signatureIdentityTitle': signatureIdentityTitle,
      'signatureIdentityTitle_hi': signatureIdentityTitleHi,
      'signatureIdentityTitle_gu': signatureIdentityTitleGu,
      
      'signatureIdentitySubtitle': signatureIdentitySubtitle,
      'signatureIdentitySubtitle_hi': signatureIdentitySubtitleHi,
      'signatureIdentitySubtitle_gu': signatureIdentitySubtitleGu,

      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    return ProfileData(
      contentHTML: map['contentHTML'] ?? '',
      contentDelta: map['contentDelta'] ?? '',
      contentHTMLHi: map['contentHTML_hi'] ?? '',
      contentDeltaHi: map['contentDelta_hi'] ?? '',
      contentHTMLGu: map['contentHTML_gu'] ?? '',
      contentDeltaGu: map['contentDelta_gu'] ?? '',
      
      coreCompetencies: List<String>.from(map['coreCompetencies'] ?? []),
      coreCompetenciesHi: List<String>.from(map['coreCompetencies_hi'] ?? []),
      coreCompetenciesGu: List<String>.from(map['coreCompetencies_gu'] ?? []),
      
      professionalHighlights: List<String>.from(map['professionalHighlights'] ?? []),
      professionalHighlightsHi: List<String>.from(map['professionalHighlights_hi'] ?? []),
      professionalHighlightsGu: List<String>.from(map['professionalHighlights_gu'] ?? []),
      
      socialInitiativeTitle: map['socialInitiativeTitle'] ?? '',
      socialInitiativeTitleHi: map['socialInitiativeTitle_hi'] ?? '',
      socialInitiativeTitleGu: map['socialInitiativeTitle_gu'] ?? '',
      
      socialVision: map['socialVision'] ?? '',
      socialVisionHi: map['socialVision_hi'] ?? '',
      socialVisionGu: map['socialVision_gu'] ?? '',
      
      socialMission: map['socialMission'] ?? '',
      socialMissionHi: map['socialMission_hi'] ?? '',
      socialMissionGu: map['socialMission_gu'] ?? '',
      
      socialObjective: map['socialObjective'] ?? '',
      socialObjectiveHi: map['socialObjective_hi'] ?? '',
      socialObjectiveGu: map['socialObjective_gu'] ?? '',
      
      philosophyOfLife: map['philosophyOfLife'] ?? '',
      philosophyOfLifeHi: map['philosophyOfLife_hi'] ?? '',
      philosophyOfLifeGu: map['philosophyOfLife_gu'] ?? '',
      
      personalAttributes: List<String>.from(map['personalAttributes'] ?? []),
      personalAttributesHi: List<String>.from(map['personalAttributes_hi'] ?? []),
      personalAttributesGu: List<String>.from(map['personalAttributes_gu'] ?? []),
      
      signatureIdentityTitle: map['signatureIdentityTitle'] ?? '',
      signatureIdentityTitleHi: map['signatureIdentityTitle_hi'] ?? '',
      signatureIdentityTitleGu: map['signatureIdentityTitle_gu'] ?? '',
      
      signatureIdentitySubtitle: map['signatureIdentitySubtitle'] ?? '',
      signatureIdentitySubtitleHi: map['signatureIdentitySubtitle_hi'] ?? '',
      signatureIdentitySubtitleGu: map['signatureIdentitySubtitle_gu'] ?? '',
      
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }
}
