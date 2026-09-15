import 'package:flutter_test/flutter_test.dart';
import 'package:docuscan/features/documents/domain/document.dart';

void main() {
  test('document preserves page order', () {
    final now=DateTime(2026,1,1);
    final d=Document(id:'1',title:'A',createdAt:now,updatedAt:now,pagePaths:const ['1.jpg','2.jpg'],ocrText:'hello');
    expect(d.pagePaths, ['1.jpg','2.jpg']);
  });
}
