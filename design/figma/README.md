# DocuScan Figma package

Figma's native `.fig` format is proprietary, so this package uses an editable SVG board plus tokens.

1. In Figma choose **File → Place image** and select `DocuScan_Figma_Import.svg`.
2. Ungroup imported vectors.
3. Convert each 390×844 phone group into a Frame.
4. Create local variables/styles from `tokens.json`.
5. Suggested component variants: DocumentCard (normal/favorite), ScanCTA, SearchField (idle/typing), CameraGuide (searching/detected), FilterChip (default/selected), PrivacyChip.

Screens: Home, Scanner, Crop, Enhance, Document Detail, Search.
