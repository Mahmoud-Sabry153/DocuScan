import 'package:sqflite/sqflite.dart';
import '../domain/document.dart';
import '../domain/document_repository.dart';
import '../../storage/data/docu_database.dart';
import '../../storage/data/local_file_store.dart';

class SqliteDocumentRepository implements DocumentRepository {
  SqliteDocumentRepository(this.database, this.files);
  final DocuDatabase database;
  final LocalFileStore files;

  Document _map(Map<String, Object?> row) => Document(
    id: row['id']! as String,
    title: row['title']! as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']! as int),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at']! as int),
    pagePaths: (row['page_paths']! as String).split('|').where((e) => e.isNotEmpty).toList(),
    ocrText: row['ocr_text']! as String,
    folder: row['folder'] as String?,
    tags: (row['tags']! as String).split('|').where((e) => e.isNotEmpty).toList(),
    favorite: (row['favorite']! as int) == 1,
    pdfPath: row['pdf_path'] as String?,
  );

  Map<String, Object?> _row(Document d) => {
    'id': d.id, 'title': d.title,
    'created_at': d.createdAt.millisecondsSinceEpoch,
    'updated_at': d.updatedAt.millisecondsSinceEpoch,
    'page_paths': d.pagePaths.join('|'), 'ocr_text': d.ocrText,
    'folder': d.folder, 'tags': d.tags.join('|'), 'favorite': d.favorite ? 1 : 0, 'pdf_path': d.pdfPath,
  };

  @override
  Future<List<Document>> getDocuments({String query = ''}) async {
    final db = await database.db;
    final q = query.trim();
    final rows = q.isEmpty
      ? await db.query('documents', orderBy: 'updated_at DESC')
      : await db.query('documents', where: 'title LIKE ? OR ocr_text LIKE ? OR tags LIKE ?', whereArgs: ['%$q%', '%$q%', '%$q%'], orderBy: 'updated_at DESC');
    return rows.map(_map).toList();
  }

  @override Future<Document?> getById(String id) async { final rows=await (await database.db).query('documents',where:'id=?',whereArgs:[id],limit:1); return rows.isEmpty?null:_map(rows.first); }
  @override Future<void> save(Document d) async => (await database.db).insert('documents', _row(d), conflictAlgorithm: ConflictAlgorithm.replace);
  @override Future<void> rename(String id,String title) async => (await database.db).update('documents',{'title':title,'updated_at':DateTime.now().millisecondsSinceEpoch},where:'id=?',whereArgs:[id]);
  @override Future<void> toggleFavorite(String id) async { final d=await getById(id); if(d==null)return; await (await database.db).update('documents',{'favorite':d.favorite?0:1},where:'id=?',whereArgs:[id]); }
  @override Future<void> delete(String id) async { await (await database.db).delete('documents',where:'id=?',whereArgs:[id]); await files.deleteDocumentFiles(id); }
}
