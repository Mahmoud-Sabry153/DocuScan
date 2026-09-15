import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../image_processing/data/isolate_image_processor.dart';
import '../../image_processing/domain/image_processor.dart';
import '../../ocr/data/mlkit_ocr_engine.dart';
import '../../storage/data/local_file_store.dart';
import '../../documents/domain/document.dart';
import '../../documents/data/sqlite_document_repository.dart';
import '../../storage/data/docu_database.dart';
import '../../pdf/data/pdf_service.dart';

class ScannerScreen extends StatefulWidget { const ScannerScreen({super.key}); @override State<ScannerScreen> createState()=>_ScannerScreenState(); }
const _filterLabels = {
  EnhancementMode.original: 'Original',
  EnhancementMode.document: 'Document',
  EnhancementMode.blackAndWhite: 'B&W',
  EnhancementMode.colorBoost: 'Color Boost',
  EnhancementMode.grayscale: 'Grayscale',
  EnhancementMode.sepia: 'Sepia',
};

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _camera; bool _busy=false; String? _error; final List<String> _pages=[];
  EnhancementMode _mode=EnhancementMode.document;
  final _files=LocalFileStore(); final _ocr=MlKitOcrEngine(); final _processor=IsolateImageProcessor();

  @override void initState(){ super.initState(); _init(); }
  Future<void> _init() async { try { final cameras=await availableCameras(); if(cameras.isEmpty) throw StateError('No camera'); final c=CameraController(cameras.first,ResolutionPreset.high,enableAudio:false,imageFormatGroup:ImageFormatGroup.jpeg); await c.initialize(); if(mounted)setState(()=>_camera=c); } catch(e){ if(mounted)setState(()=>_error='Camera unavailable or permission denied.'); } }
  @override void dispose(){_camera?.dispose(); _ocr.close(); super.dispose();}

  Future<void> _capture() async {
    if(_busy||_camera==null||!_camera!.value.isInitialized)return; setState(()=>_busy=true);
    try { final shot=await _camera!.takePicture(); final enhanced=await _processor.enhance(shot.path, mode: _mode); if(mounted)setState(()=>_pages.add(enhanced)); }
    catch(e){ if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Capture failed. Try again.'))); }
    finally { if(mounted)setState(()=>_busy=false); }
  }

  Future<void> _finish() async {
    if(_pages.isEmpty)return; setState(()=>_busy=true); final id=const Uuid().v4();
    try {
      final persisted=<String>[]; final text=StringBuffer();
      for(var i=0;i<_pages.length;i++){ final page=await _files.persistPage(id,_pages[i],i+1); persisted.add(page); final result=await _ocr.recognize(page); if(result.text.trim().isNotEmpty) text.writeln(result.text); }
      final pdf=await PdfService(_files).create(id,persisted);
      final now=DateTime.now();
      final doc=Document(id:id,title:'Scan ${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}',createdAt:now,updatedAt:now,pagePaths:persisted,ocrText:text.toString(),pdfPath:pdf);
      await SqliteDocumentRepository(DocuDatabase(),_files).save(doc);
      if(mounted)Navigator.pop(context,true);
    } catch(e){ if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not finish scan: $e'))); }
    finally { if(mounted)setState(()=>_busy=false); }
  }

  @override Widget build(BuildContext context){
    if(_error!=null)return Scaffold(appBar:AppBar(title:const Text('Scanner')),body:Center(child:Padding(padding:const EdgeInsets.all(32),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.no_photography_outlined,size:56),const SizedBox(height:16),Text(_error!,textAlign:TextAlign.center)]))));
    if(_camera==null)return const Scaffold(body:Center(child:CircularProgressIndicator()));
    return Scaffold(backgroundColor:Colors.black, appBar:AppBar(backgroundColor:Colors.black,foregroundColor:Colors.white,title:Text('${_pages.length} page${_pages.length==1?'':'s'}'),actions:[TextButton(onPressed:_pages.isEmpty||_busy?null:_finish,child:const Text('Done'))]),
      body:Stack(children:[Positioned.fill(child:CameraPreview(_camera!)),Positioned.fill(child:IgnorePointer(child:CustomPaint(painter:_GuidePainter()))),Positioned(left:0,right:0,bottom:110,child:_FilterStrip(mode:_mode,onChanged:(m)=>setState(()=>_mode=m))),Positioned(left:16,right:16,bottom:24,child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[IconButton.filledTonal(onPressed:null,icon:const Icon(Icons.flash_auto)),GestureDetector(onTap:_capture,child:Container(width:78,height:78,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:Colors.white,width:5)),child:Padding(padding:const EdgeInsets.all(7),child:DecoratedBox(decoration:BoxDecoration(shape:BoxShape.circle,color:_busy?Colors.grey:Colors.white))))),Badge(label:Text('${_pages.length}'),isLabelVisible:_pages.isNotEmpty,child:IconButton.filledTonal(onPressed:(){},icon:const Icon(Icons.photo_library_outlined))) ])),if(_busy)const Positioned.fill(child:ColoredBox(color:Color(0x55000000),child:Center(child:CircularProgressIndicator()))) ]));
  }
}
class _FilterStrip extends StatelessWidget {
  const _FilterStrip({required this.mode, required this.onChanged});
  final EnhancementMode mode; final ValueChanged<EnhancementMode> onChanged;
  @override Widget build(BuildContext context)=>SizedBox(height:44,child:ListView(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:16),children:EnhancementMode.values.map((m){
    final selected=m==mode;
    return Padding(padding:const EdgeInsets.only(right:8),child:GestureDetector(onTap:()=>onChanged(m),child:AnimatedContainer(duration:const Duration(milliseconds:150),padding:const EdgeInsets.symmetric(horizontal:16,vertical:10),decoration:BoxDecoration(color:selected?Colors.white:Colors.white24,borderRadius:BorderRadius.circular(20)),child:Text(_filterLabels[m]!,style:TextStyle(color:selected?Colors.black:Colors.white,fontWeight:FontWeight.w600,fontSize:13)))));
  }).toList()));
}
class _GuidePainter extends CustomPainter { @override void paint(Canvas c,Size s){final p=Paint()..color=const Color(0xAA8BE3C1)..style=PaintingStyle.stroke..strokeWidth=3; final r=Rect.fromLTWH(s.width*.08,s.height*.12,s.width*.84,s.height*.68); c.drawRRect(RRect.fromRectAndRadius(r,const Radius.circular(18)),p);} @override bool shouldRepaint(covariant CustomPainter oldDelegate)=>false; }
