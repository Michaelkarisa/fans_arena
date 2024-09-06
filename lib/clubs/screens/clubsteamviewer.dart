import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../appid.dart';
import '../../clubs/screens/clubteamtable.dart';
import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import '../data/lineup.dart';
class Clubsteamviwer extends StatefulWidget {
  String userId;
  String image;
  String name;
  Clubsteamviwer({super.key,
    required this.userId,
    required this.image,
    required this.name});
  @override
  State<Clubsteamviwer> createState() => _ClubsteamviwerState();
}
class _ClubsteamviwerState extends State<Clubsteamviwer> {
  ScrollController controller=ScrollController();
  bool status=false;
  int rank=1;
  double radius=16;
  final formKey=GlobalKey<FormState>();
  bool mdown=true;
  bool set=false;
  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() {
          mdown=false;
        });
      }else{
        setState(() {
          mdown=true;
        });
      }
    });
  }


  bool isLoading=true;

  List<Map<String, dynamic>> tableColumns = [];
  List<Map<String, dynamic>> dRows = [];
  List<List<String>> data = [];

  Future<void> _add()async{
    showDialog(
        barrierDismissible: false,
        context: context, builder: (context)=>AlertDialog(
      content: SizedBox(
        height: 80,
        child:dRows.isEmpty||tableColumns.isEmpty? Text("tablecolumn empty or dRows empty"):Column(
          children: [
            CircularProgressIndicator(),
            Text('Generating PDF..')
          ],
        ),
      ),
    ));
    try {
      List<List<String>> data1 = [];
      List<String> Cheadings = [];
      List<List<String>> rows = [];
      for (var cH in tableColumns) {
        String ch = cH['fn'];
        Cheadings.add(ch);
      }
      for (var rw in dRows) {
        List<String> row = [];
        int rnk = dRows.indexOf(rw);
        for (var cH in tableColumns) {
          int i = tableColumns.indexOf(cH);
          if (i == 0) {
            String ch = "${rnk + 1}";
            row.add(ch);
          } else if (i == 1) {
            UsersData? appUsage = await DatabaseHelper2Users.instance.getUser(
                rw[cH['fn']]);
            if (appUsage != null) {
              // row.add(appUsage.user.url);
              row.add(appUsage.user.name);
            }
          } else {
            String ch = rw[cH['fn']];
            row.add(ch);
          }
        }
        rows.add(row);
      }
      data1.add(Cheadings);
      data1.addAll(rows);
      setState(() {
        data = data1;
      });
    }catch(e){
      showDialog(context: context, builder: (context)=>AlertDialog(
        content: Text(e.toString()),
      ));
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text("Club's Team",style: TextStyle(color: Colors.black),),actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: ()async{
              await _add();
              generateAndPrintPDF();
            },
          ),
        ],),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: FutureBuilder<QuerySnapshot>(
              future:FirebaseFirestore.instance
                  .collection('Clubs')
                  .doc(widget.userId).collection('clubsteam').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No Team Members'));
                } else {
                  final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!.docs;
                  List<Map<String, dynamic>> tableColumns1 = [];
                  List<Map<String, dynamic>> dRows1 = [];
                  for (final document in likeDocuments) {
                    final List<dynamic> likesArray = document['clubsteam'];
                    final List<dynamic> likesArray1 = document['clubsTeamTable'];
                    dRows1.addAll(likesArray.cast<Map<String, dynamic>>());//.where((element) => element['status']=='1'));
                    tableColumns1.addAll(likesArray1.cast<Map<String, dynamic>>());
                    tableColumns=tableColumns1;
                    dRows=dRows1;
                  }
                  return  DataTable(
                      columnSpacing: MediaQuery.of(context).size.width*0.08,
                      columns: tableColumns1
                          .map((d) => DataColumn(
                          label: SizedBox(
                            height: 30,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(d['fn']),
                            ),
                          )))
                          .toList(),
                      rows: dRows1.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> d = entry.value;
                        return DataRow(cells: [
                          DataCell(Text('${index + 1}')),
                          ...tableColumns1
                              .where(
                                  (col) => col['fn'] != tableColumns1[0]['fn'])
                              .map((col) {
                            String columnName = col['fn'];
                            int i = tableColumns1.indexOf(col);
                            return DataCell(
                              i == 1 ? CustomNameAvatar(userId:d[columnName] ?? '',radius: 16, style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ), maxsize: 70,click: true,)
                                  : SizedBox(
                                      height: 30,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(d[columnName] ?? ''),
                                      )),
                            );
                          }),
                        ]);
                      }).toList()
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
  Future<Uint8List> generatePDF() async {
    final pdf = pw.Document();
    final tableHeaders = data.first;
    final tableData = data.sublist(1);
    pw.MemoryImage? limage;
    if (profileimage.isNotEmpty) {
      final response = await http.get(Uri.parse(widget.image));
      final imageBytes = response.bodyBytes;
      limage = pw.MemoryImage(imageBytes);
    }
    List<pw.TableRow> tableRows = [];
    tableRows.add(
      pw.TableRow(
        children: tableHeaders.map((header) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              header,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
    for (var row in tableData) {
      // final imageUrl = row[1];
      //  pw.MemoryImage? image;
      //  if (imageUrl.isNotEmpty) {
      //    final response = await http.get(Uri.parse(imageUrl));
      //   final imageBytes = response.bodyBytes;
      //  image = pw.MemoryImage(imageBytes);
      //}
      tableRows.add(
        pw.TableRow(children: row.map((cell) {
            return pw.Text(cell);
          }).toList(),
        ),
      );
    }
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text("CLUB'S TEAM TABLE", style: pw.TextStyle(
                fontSize: 30,
                fontWeight: pw.FontWeight.bold,
              ),),
              pw.SizedBox(height: 20),
              limage != null?
              pw.ClipRRect(
                horizontalRadius: 35,
                verticalRadius: 35,
                child: pw.Image(
                    fit:pw.BoxFit.fill,
                    height: 70,
                    width: 70,
                    limage),
              ):pw.SizedBox.shrink(),
              pw.SizedBox(height: 10),
              pw.Text(
                widget.name,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: tableRows,
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }
  void generateAndPrintPDF() async {
    try {
      final pdfBytes = await generatePDF();
      Navigator.of(context,rootNavigator: true).pop();
      await Future.delayed(Duration(seconds: 1));
      showDialog(barrierDismissible: false,context: context, builder: (context)=>AlertDialog(
        content: Text('PDF Generated'),
      ));
      await Future.delayed(Duration(seconds: 1));
      Navigator.of(context,rootNavigator: true).pop();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    }catch(e){
      showDialog(context: context, builder: (context)=>AlertDialog(
        content: Text(e.toString()),
      ));
    }
  }
}