import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileData {
  // ── Introduction (Quill rich text) ──────────────────────────────────────────
  String contentHTML;
  String contentDelta;

  // ── Structured sections ──────────────────────────────────────────────────────
  List<String> coreCompetencies;
  List<String> professionalHighlights;

  // Social Initiative
  String socialInitiativeTitle;
  String socialVision;
  String socialMission;
  String socialObjective;

  // Philosophy of Life
  String philosophyOfLife;

  // Personal Attributes
  List<String> personalAttributes;

  DateTime? lastUpdated;

  ProfileData({
    this.contentHTML = '',
    this.contentDelta = '',
    List<String>? coreCompetencies,
    List<String>? professionalHighlights,
    this.socialInitiativeTitle = '',
    this.socialVision = '',
    this.socialMission = '',
    this.socialObjective = '',
    this.philosophyOfLife = '',
    List<String>? personalAttributes,
    this.lastUpdated,
  })  : coreCompetencies       = coreCompetencies       ?? [],
        professionalHighlights  = professionalHighlights  ?? [],
        personalAttributes      = personalAttributes      ?? [];

  Map<String, dynamic> toMap() {
    return {
      'contentHTML':             contentHTML,
      'contentDelta':            contentDelta,
      'coreCompetencies':        coreCompetencies,
      'professionalHighlights':  professionalHighlights,
      'socialInitiativeTitle':   socialInitiativeTitle,
      'socialVision':            socialVision,
      'socialMission':           socialMission,
      'socialObjective':         socialObjective,
      'philosophyOfLife':        philosophyOfLife,
      'personalAttributes':      personalAttributes,
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    return ProfileData(
      contentHTML:            map['contentHTML']            ?? '',
      contentDelta:           map['contentDelta']           ?? '',
      coreCompetencies:       List<String>.from(map['coreCompetencies']       ?? []),
      professionalHighlights: List<String>.from(map['professionalHighlights'] ?? []),
      socialInitiativeTitle:  map['socialInitiativeTitle']  ?? '',
      socialVision:           map['socialVision']           ?? '',
      socialMission:          map['socialMission']          ?? '',
      socialObjective:        map['socialObjective']        ?? '',
      philosophyOfLife:       map['philosophyOfLife']       ?? '',
      personalAttributes:     List<String>.from(map['personalAttributes']     ?? []),
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }
}
