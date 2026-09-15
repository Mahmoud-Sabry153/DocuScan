import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../domain/document.dart';

class DocumentDetailScreen extends StatelessWidget { const DocumentDetailScreen({super.key,required this.document}); final Document document;
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:Text(document.title),actions:[IconButton(onPressed:document.pdfPath==null?null:()=>SharePlus.instance.share(ShareParams(files:[XFile(document.pdfPath!)])),icon:const Icon(Icons.ios_share))]),body:ListView(padding:const EdgeInsets.all(20),children:[
    SizedBox(height:420,child:PageView.builder(itemCount:document.pagePaths.length,itemBuilder:(_,i)=>Padding(padding:const EdgeInsets.only(right:10),child:ClipRRect(borderRadius:BorderRadius.circular(20),child:Image.file(File(document.pagePaths[i]),fit:BoxFit.contain))))),
    const SizedBox(height:20),Row(children:[Expanded(child:_Stat(icon:Icons.layers_outlined,label:'Pages',value:'${document.pagePaths.length}')),const SizedBox(width:12),const Expanded(child:_Stat(icon:Icons.text_snippet_outlined,label:'OCR',value:'On-device'))]),
    const SizedBox(height:24),const Text('Recognized text',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),const SizedBox(height:10),SelectableText(document.ocrText.trim().isEmpty?'No text was recognized on these pages.':document.ocrText),
    if(document.pdfPath!=null)...[const SizedBox(height:24),FilledButton.icon(onPressed:()=>Printing.layoutPdf(onLayout:(_)=>File(document.pdfPath!).readAsBytes()),icon:const Icon(Icons.picture_as_pdf_outlined),label:const Text('Preview / Print PDF'))]
  ]));
}
class _Stat extends StatelessWidget { const _Stat({required this.icon,required this.label,required this.value}); final IconData icon; final String label,value; @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(16)),child:Row(children:[Icon(icon),const SizedBox(width:10),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(color:Colors.black45,fontSize:12)),Text(value,style:const TextStyle(fontWeight:FontWeight.w700))])])) ;}
