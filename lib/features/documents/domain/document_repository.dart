import 'document.dart';

abstract interface class DocumentRepository {
  Future<List<Document>> getDocuments({String query = ''});
  Future<Document?> getById(String id);
  Future<void> save(Document document);
  Future<void> delete(String id);
  Future<void> rename(String id, String title);
  Future<void> toggleFavorite(String id);
}
