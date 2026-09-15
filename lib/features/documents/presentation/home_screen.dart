import 'dart:io';
import 'package:flutter/material.dart';
import '../../scanner/presentation/scanner_screen.dart';
import '../../storage/data/docu_database.dart';
import '../../storage/data/local_file_store.dart';
import '../data/sqlite_document_repository.dart';
import '../domain/document.dart';
import 'document_detail_screen.dart';

class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState()=>_HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  late final SqliteDocumentRepository repo=SqliteDocumentRepository(DocuDatabase(),LocalFileStore());
  var query='';
  Future<List<Document>> _load()=>repo.getDocuments(query:query);
  Future<void> _scan() async { final changed=await Navigator.push<bool>(context,MaterialPageRoute(builder:(_)=>const ScannerScreen())); if(changed==true&&mounted)setState((){}); }
  @override Widget build(BuildContext context)=>Scaffold(
    body:SafeArea(child:RefreshIndicator(onRefresh:()async=>setState((){}),child:CustomScrollView(slivers:[
      SliverPadding(padding:const EdgeInsets.fromLTRB(20,18,20,8),sliver:SliverToBoxAdapter(child:Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('DocuScan',style:TextStyle(fontSize:28,fontWeight:FontWeight.w800)),Text('Private. Local. Searchable.',style:TextStyle(color:Colors.black54))])),IconButton.filledTonal(onPressed:(){},icon:const Icon(Icons.lock_outline))]))),
      SliverPadding(padding:const EdgeInsets.fromLTRB(20,8,20,14),sliver:SliverToBoxAdapter(child:TextField(onChanged:(v)=>setState(()=>query=v),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search titles, tags, or scanned text…')))),
      SliverPadding(padding:const EdgeInsets.symmetric(horizontal:20),sliver:SliverToBoxAdapter(child:_QuickScan(onTap:_scan))),
      const SliverPadding(padding:EdgeInsets.fromLTRB(20,24,20,12),sliver:SliverToBoxAdapter(child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('Recent documents',style:TextStyle(fontSize:18,fontWeight:FontWeight.w700)),Text('Local only',style:TextStyle(color:Colors.black45))]))),
      FutureBuilder<List<Document>>(future:_load(),builder:(context,s){if(s.connectionState!=ConnectionState.done)return const SliverFillRemaining(child:Center(child:CircularProgressIndicator())); final docs=s.data??[]; if(docs.isEmpty)return SliverFillRemaining(hasScrollBody:false,child:Center(child:Padding(padding:const EdgeInsets.all(30),child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.description_outlined,size:62,color:Colors.black26),const SizedBox(height:12),Text(query.isEmpty?'No scans yet':'No matching documents',style:const TextStyle(fontSize:18,fontWeight:FontWeight.w700)),const SizedBox(height:6),const Text('Scan a document and OCR text will stay on this device.',textAlign:TextAlign.center,style:TextStyle(color:Colors.black54))])))); return SliverPadding(padding:const EdgeInsets.fromLTRB(20,0,20,110),sliver:SliverList.builder(itemCount:docs.length,itemBuilder:(context,i)=>Padding(padding:const EdgeInsets.only(bottom:12),child:_DocumentCard(doc:docs[i],onTap:()async{await Navigator.push(context,MaterialPageRoute(builder:(_)=>DocumentDetailScreen(document:docs[i])));if(mounted)setState((){});}))));})
    ]))), floatingActionButton:FloatingActionButton.extended(onPressed:_scan,icon:const Icon(Icons.document_scanner),label:const Text('Scan')),
  );
}
class _QuickScan extends StatelessWidget { const _QuickScan({required this.onTap}); final VoidCallback onTap; @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF445CF6),Color(0xFF7083FF)]),borderRadius:BorderRadius.circular(24)),child:Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Scan a document',style:TextStyle(color:Colors.white,fontSize:21,fontWeight:FontWeight.w800)),SizedBox(height:6),Text('Auto enhance + on-device OCR',style:TextStyle(color:Colors.white70))])),FilledButton.tonal(onPressed:onTap,child:const Icon(Icons.add_a_photo_outlined))])); }
class _DocumentCard extends StatelessWidget { const _DocumentCard({required this.doc,required this.onTap}); final Document doc; final VoidCallback onTap; @override Widget build(BuildContext context)=>Card(child:InkWell(borderRadius:BorderRadius.circular(20),onTap:onTap,child:Padding(padding:const EdgeInsets.all(12),child:Row(children:[ClipRRect(borderRadius:BorderRadius.circular(14),child:SizedBox(width:72,height:88,child:doc.pagePaths.isEmpty?const ColoredBox(color:Color(0xFFE9EBF4)):Image.file(File(doc.pagePaths.first),fit:BoxFit.cover,cacheWidth:180))),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(doc.title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w700,fontSize:16)),const SizedBox(height:8),Text('${doc.pagePaths.length} pages • OCR indexed',style:const TextStyle(color:Colors.black54)),const SizedBox(height:8),Text(doc.ocrText.trim().replaceAll('\n',' '),maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Colors.black45,fontSize:12))])),Icon(doc.favorite?Icons.star:Icons.chevron_right,color:doc.favorite?Colors.amber:Colors.black38)])))); }
