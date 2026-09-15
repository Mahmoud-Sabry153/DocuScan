# DocuScan

Portfolio-grade Flutter/Android starter for a privacy-first document scanner. The project keeps files, OCR text, and metadata local by default.

## What is implemented
- Camera preview and multi-page capture using Flutter `camera`.
- Background/isolate image resizing + grayscale/document enhancement.
- On-device OCR through ML Kit text recognition.
- App-private document file lifecycle and SQLite metadata/search.
- Multi-page PDF generation, preview/print and share.
- Biometric service abstraction with `local_auth`.
- Clean, feature-first boundaries for scanner / OCR / processing / documents / PDF / search / security.
- Android MethodChannel boundary for native document CV.
- Unit/widget/integration-test scaffolding.
- Figma-ready editable SVG design board and design tokens under `design/figma/`.

## Important production boundary
The native CV channel is intentionally isolated, but the bundled Kotlin implementation only returns a conservative document quad and reports perspective correction as `NOT_ENABLED`. For production-grade edge detection/perspective warp, enable either:
1. a maintained document-scanner SDK/package, or
2. an OpenCV Android module behind `NativeDocumentDetector`.

This avoids pretending a weak heuristic is production document detection. Flutter UI/business code does not depend on the native implementation.

## Architecture
`presentation -> domain abstractions -> data/services -> platform/files/database`

Repositories are the source of truth for document metadata. Services wrap host/platform concerns. This follows separation-of-concerns guidance and makes camera/OCR/CV testable behind interfaces.

## Image pipeline
1. Capture JPEG at high resolution.
2. Optional native document quad detection.
3. Crop/perspective correction (native CV boundary).
4. Resize working image to <=2400 px width when needed.
5. Enhancement in a helper isolate.
6. Persist final page into app-private document directory.
7. OCR each persisted page.
8. Store OCR text in SQLite for local search.
9. Generate compressed multi-page PDF on demand/finish.

Never keep all decoded page bitmaps resident at once. UI thumbnails use `cacheWidth`; processing works one page at a time.

## Storage strategy
- Binary pages/PDF: application documents directory under `docuscan/documents/<uuid>/`.
- Metadata/search text: SQLite.
- Deletion: metadata row removed, then document directory recursively deleted.
- Android backup disabled in the manifest for privacy.
- No network dependency or upload endpoint is included.

## Flutter/native boundary
Native code is limited to capabilities where platform CV is justified. `MethodChannel('com.docuscan/native_cv')` is hidden behind `DocumentDetector`; the rest of the app is platform-agnostic.

## Run
This archive was generated in an environment without Flutter/Dart installed, so it could not be compiled here. On a machine with current Flutter:

```bash
flutter pub get
flutter run
flutter test
flutter test integration_test
```

If Android launcher resources are missing, run `flutter create . --platforms=android` once, then preserve the included `MainActivity.kt`, manifest and Gradle settings.

## Production hardening checklist
- Add real CV implementation and crop editor wired to the quad model.
- Add encrypted DB/file key management if the threat model requires encryption at rest.
- Add migration/versioning tests for SQLite.
- Add low-storage preflight and disk-quota UI.
- Add crash-safe transaction/journal around capture finalization.
- Add Android scoped export using SAF if exporting directly to user-selected folders.
- Add OCR language model selection and accessibility/localization.
- Run memory profiling on low-RAM Android devices and large 20–50 page documents.
