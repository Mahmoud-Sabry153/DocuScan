import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../core/error/app_failure.dart';

class LocalFileStore {
  Future<Directory> _root() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'docuscan'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> documentDir(String id) async {
    final dir = Directory(p.join((await _root()).path, 'documents', id));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<String> persistPage(String documentId, String sourcePath, int page) async {
    try {
      final dir = await documentDir(documentId);
      final dest = p.join(dir.path, 'page_${page.toString().padLeft(3, '0')}.jpg');
      await File(sourcePath).copy(dest);
      return dest;
    } catch (e) {
      throw StorageFailure('Could not persist scan page.', e);
    }
  }

  Future<void> deleteDocumentFiles(String id) async {
    final dir = await documentDir(id);
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  Future<int> storageBytes() async {
    final root = await _root();
    var total = 0;
    await for (final entity in root.list(recursive: true)) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }
}
