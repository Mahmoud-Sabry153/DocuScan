import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DocuDatabase {
  Database? _db;
  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final base = await getDatabasesPath();
    return openDatabase(
      p.join(base, 'docuscan.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute("CREATE TABLE documents(id TEXT PRIMARY KEY, title TEXT NOT NULL, created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL, page_paths TEXT NOT NULL, ocr_text TEXT NOT NULL DEFAULT '', folder TEXT, tags TEXT NOT NULL DEFAULT '', favorite INTEGER NOT NULL DEFAULT 0, pdf_path TEXT)");
        await db.execute('CREATE INDEX idx_documents_updated ON documents(updated_at DESC)');
        await db.execute('CREATE INDEX idx_documents_title ON documents(title)');
      },
    );
  }
}
