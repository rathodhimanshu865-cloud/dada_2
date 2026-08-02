# Implementation Plan - Dynamic About/Profile Page with Flutter Quill

Implement a dynamic, admin-editable "About/Profile" page using Firestore for data storage and `flutter_quill` as the rich text editor. This approach avoids the `platformViewRegistry` errors encountered with previous editors by using a pure Flutter implementation for the editor.

## User Review Required

> [!IMPORTANT]
> - **Data Format**: I will store both the Quill Delta (for accurate editor state) and the converted HTML (for efficient user-side rendering) in Firestore.
> - **Rich Text Capabilities**: The editor will support bold, italic, headings, lists, and basic alignment.
> - **Layout Preservation**: The user-side rendering will maintain the "premium" design by applying custom styles to the HTML elements via `flutter_widget_from_html`.

## Proposed Changes

### Core Logic & Data

#### [profile_model.dart](file:///D:/dada_2/lib/models/profile_model.dart)
- Update `ProfileData` to include `contentDelta` (Stringified JSON) and `contentHTML`.
- Update `toMap` and `fromMap` to handle these fields.

#### [profile_controller.dart](file:///D:/dada_2/lib/controllers/profile_controller.dart)
- Update `saveProfile` to accept both HTML and Delta.
- Ensure the stream listener correctly populates the `ProfileData` object.

---

### Admin Interface

#### [about_profile_management.dart](file:///D:/dada_2/lib/views/admin/about_profile_management.dart)
- Replace `html_editor_plus` with `flutter_quill`.
- Implement `QuillController` initialization from stored Delta.
- Add a toolbar and editor widget.
- Implement `_saveProfile` logic:
    - Get Delta from `QuillController`.
    - Convert Delta to HTML using `vsc_quill_delta_to_html`.
    - Save both to Firestore via `ProfileController`.

---

### User Interface

#### [about_jignesh_dada_page.dart](file:///D:/dada_2/lib/views/user_side/about_jignesh_dada_page.dart)
- Verify `HtmlWidget` correctly fetches `contentHTML` from `ProfileController`.
- Refine custom styles in `HtmlWidget` to match the site's premium typography (fonts, spacing, teal/gold accents).

---

## Verification Plan

### Automated Tests
- No automated tests are requested, but I will perform manual verification.

### Manual Verification
1.  **Build Verification**: Run `flutter build web` to ensure no `platformViewRegistry` errors or build failures occur with the new dependencies.
2.  **Editor Functionality**:
    - Open Admin Dashboard -> Profile / About.
    - Type text, apply Bold, Italic, H1, H2, and Bullet lists.
    - Click "SAVE CHANGES".
3.  **Real-time Update**:
    - Keep two tabs open: one on Admin Editor, one on User About Page.
    - Verify that clicking "SAVE" in Admin updates the User side instantly (via Firestore snapshots).
4.  **Rich Text Rendering**:
    - Verify that headings appear in Teal with the gold border-bottom as defined in `about_jignesh_dada_page.dart`.
    - Verify lists and text styling are correctly preserved.
