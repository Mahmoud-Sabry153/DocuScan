import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;
import '../../storage/data/local_file_store.dart';
import '../../../core/error/app_failure.dart';

class PdfService {
  PdfService(this.files); final LocalFileStore files;
  Future<String> create(String documentId, List<String> pagePaths) async {
    try {
      final pdf = pw.Document(compress: true);
      for (final path in pagePaths) {
        final memory = pw.MemoryImage(await File(path).readAsBytes());
        pdf.addPage(pw.Page(margin: pw.EdgeInsets.zero, build: (_) => pw.Center(child: pw.Image(memory, fit: pw.BoxFit.contain))));
      }
      final dir = await files.documentDir(documentId);
      final out = p.join(dir.path, 'document.pdf');
      await File(out).writeAsBytes(await pdf.save(), flush: true);
      return out;
    } catch (e) { throw PdfFailure('PDF generation failed.', e); }
  }
}
