class Document {
  const Document({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.pagePaths,
    required this.ocrText,
    this.folder,
    this.tags = const [],
    this.favorite = false,
    this.pdfPath,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> pagePaths;
  final String ocrText;
  final String? folder;
  final List<String> tags;
  final bool favorite;
  final String? pdfPath;
}
