# Architecture decisions

## Privacy
No HTTP client is present. Scans are created in app-private storage and indexed locally. Sharing only occurs after explicit user action.

## Performance
Decoded pixels are short-lived. Enhancement runs in `Isolate.run`; repository lists contain file paths, not in-memory images. Thumbnails request reduced decode width.

## Failures
The `AppFailure` hierarchy separates camera, OCR, processing, storage and PDF failures. UI paths should translate these into actionable states rather than expose raw exceptions.

## Test seams
`DocumentRepository`, `OcrEngine`, `ImageProcessor`, and `DocumentDetector` are interfaces. Substitute fakes in tests; keep plugin calls out of domain code.
