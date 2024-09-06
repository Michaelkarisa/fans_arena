import 'dart:async';
import 'package:fans_arena/appid.dart';
import 'package:fans_arena/clubs/components/headerwidgetteamsearch.dart';
import 'package:fans_arena/clubs/data/lineup.dart';
import 'package:fans_arena/clubs/screens/eventsclubs.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/screens/accountfanviewer.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'accountclubviewer.dart';
import 'checklist.dart';
import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
class Clubteamtable extends StatefulWidget {
  String userId;
  Clubteamtable({super.key, required this.userId,});

  @override
  State<Clubteamtable> createState() => _ClubteamtableState();
}

class _ClubteamtableState extends State<Clubteamtable> {

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
    getAllData();
  }

  Set<String>docIds={};

  late Stream<QuerySnapshot> stream;
  void getAllData()async{
    try {
      stream = FirebaseFirestore.instance
          .collection('Clubs')
          .doc(widget.userId)
          .collection('clubsteam')
          .snapshots();
      stream.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<QueryDocumentSnapshot> docs = snapshot.docs;
          List<Map<String, dynamic>> allLikes = [];
          List<Map<String, dynamic>> allLikes1 = [];
          for (final doc in docs) {
            docIds.add(doc.id);
            final List<Map<String,dynamic>> chats = List<Map<String,dynamic>>.from(doc['clubsteam']);
            final List<Map<String,dynamic>> chats1 = List<Map<String,dynamic>>.from(doc['clubsTeamTable']);
            allLikes.addAll(chats);
            allLikes1.addAll(chats1);
          }
          setState(() {
            isLoading=false;
            dRows=allLikes;//.where((element) => element['status']=='1').toList();
            tableColumns=allLikes1;
          });
        } else {
        }
      });
    } catch (e) {
    }
  }
  bool isLoading=true;
  List<Map<String, dynamic>> tableColumns = [
    {'fn':'Rank'},
    {'fn':'Club'},
  ];
  List<Map<String, dynamic>> dRows = [];

  TextEditingController tc = TextEditingController();
  TextEditingController vc = TextEditingController();
  TextEditingController ec = TextEditingController();
  TextEditingController club = TextEditingController();
  String selectedColumn = '';
  String id = '';

  void _addNewColumn() {
    setState(() {
      String newColumnName = tc.text;
      if (newColumnName.isNotEmpty) {
        tableColumns.add({'fn': newColumnName});
        for (var d in dRows) {
          d[newColumnName] = '0';
        }
      }
    });
  }

  void _editColumnH() {
    setState(() {
      String newColumnName = ec.text;
      if (newColumnName.isNotEmpty && selectedColumn.isNotEmpty) {
        if (tableColumns.any((element) => element['fn'] != newColumnName)) {
          for (var column in tableColumns) {
            if (column['fn'] == selectedColumn) {
              column['fn'] = newColumnName;
            }
          }
          for (var row in dRows) {
            row[newColumnName] = row.remove(selectedColumn);
          }
          selectedColumn = newColumnName;
        }
      }
    });
  }

  void _editColumnV() {
    setState(() {
      String newValue = vc.text;
      if (newValue.isNotEmpty && selectedColumn.isNotEmpty) {
        var row = dRows.firstWhere((element) => element[tableColumns[1]['fn']] == id);
        if(selectedColumn!=tableColumns[1]['fn']) {
          row[selectedColumn] = newValue;
        }
      }
    });
  }

  void _addRow() {
    setState(() {
      if (club.text.isNotEmpty) {
        Map<String, dynamic> data = {};
        for (var d in tableColumns) {
          int i = tableColumns.indexOf(d);
          if (i == 1) {
            data[d['fn']] = club.text;
          } else if (i > 1) {
            data[d['fn']] = '0';
          } else {
            data[d['fn']] = '';
          }
        }
        dRows.add(data);
      }
    });
  }
  bool ascending=true;

  void _removeColumn() {
    setState(() {
      if (selectedColumn.isNotEmpty && selectedColumn != tableColumns[0]['fn'] && selectedColumn != tableColumns[1]['fn']) {
        tableColumns.removeWhere((element) => element['fn'] == selectedColumn);
        for (var row in dRows) {
          row.remove(selectedColumn);
        }
        selectedColumn = '';
      }
    });
  }

  Future<void>  updateTable() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          height: 80,
          child: Column(
            children: [
              CircularProgressIndicator(),
              Text('Updating table...')
            ],
          ),
        ),
      ),
    );
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      for (var docid in docIds) {
        await firestore.collection('Clubs').doc(widget.userId).collection(
            'clubsteam').doc(docid).update({
          'clubsTeamTable': tableColumns,
          'clubsteam': dRows,
        });
      }
      Navigator.of(context, rootNavigator: true).pop();
      await Future.delayed(Duration(seconds: 1));
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              content: SizedBox(
                height: 80,
                child: Text('Table Updated'),
              ),
            ),
      );
    }catch(e){
      Navigator.of(context, rootNavigator: true).pop();
      await Future.delayed(Duration(seconds: 1));
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("error"),
              content: SizedBox(
                height: 80,
                child: Text(e.toString()),
              ),
            ),
      );
    }
  }
  void _sort(){
    if(ascending){
      dRows.sort((a,b){
        int adate = int.tryParse(a[selectedColumn])??0;
        int bdate = int.tryParse(b[selectedColumn])??0;
        return adate.compareTo(bdate);
      });}else{
      dRows.sort((a,b){
        int adate = int.tryParse(a[selectedColumn])??0;
        int bdate = int.tryParse(b[selectedColumn])??0;
        return bdate.compareTo(adate);
      });
    }
  }

  void _removeRow(){
    setState(() {
      dRows.removeWhere((element) => element[selectedColumn]==id);
    });
  }
  ScrollController controller=ScrollController();
 bool status=false;
int rank=1;
double radius=16;
  final formKey=GlobalKey<FormState>();
  bool mdown=true;
  bool set=false;

  List<List<String>> data = [];

  Future<void> _add()async{
    showDialog(
        barrierDismissible: false,
        context: context, builder: (context)=>AlertDialog(
      content: SizedBox(
        height: 80,
        child: Column(
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
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: const Text("Club's Team",style: TextStyle(color: Colors.black),),
          actions: [
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(onPressed: (){
                      setState(() {
                        set=!set;
                      });
                    }, icon: Icon(set?Icons.close:Icons.add,color: Colors.black,)),
                    IconButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>CheckList(tableColumns: tableColumns, dRow:dRows, navf: 'Club',)));
                    }, icon: const Icon(Icons.format_list_bulleted,color: Colors.black,),
                    ) ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.print),
              onPressed: ()async{
                await _add();
                generateAndPrintPDF();
              },
            ),
          ],
        ),
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: NestedScrollView(
                controller: controller,
                headerSliverBuilder: (context, _) {
                  return [
                    SliverToBoxAdapter(
                        child: AnimatedContainer(
                            duration: const Duration(seconds: 1),
                            height: set?230:0,
                            child: const HeaderWidgetclubsteams(),
                            )
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const Text(
                            'Edit Table',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            height: 200,
                            margin: const EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(width: 1.5, color: Colors.grey[400]!),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              child: TextFormField(
                                                controller: tc,
                                                validator: (value){
                                                  if(value!.length>10){
                                                    return "Max length exceeded";
                                                  }else{
                                                    return null;
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                  const EdgeInsets.only(left: 5, bottom: 0, top: 0),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  labelText: 'Column name',
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Container(
                                                height: 35,
                                                width: MediaQuery.of(context).size.width * 0.25,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(50),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: FloatingActionButton(
                                                  elevation: 1,
                                                  foregroundColor: Colors.blue,
                                                  backgroundColor: Colors.blue,
                                                  onPressed: _addNewColumn,
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(10.0),
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      'Add column',
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              child: TextFormField(
                                                controller: ec,
                                                validator: (value){
                                                  if(value!.length>10){
                                                    return "Max length exceeded";
                                                  }else{
                                                    return null;
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                  const EdgeInsets.only(left: 5, bottom: 0, top: 0),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  labelText: 'Column name',
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Container(
                                                height: 35,
                                                width: MediaQuery.of(context).size.width * 0.25,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(50),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: FloatingActionButton(
                                                  elevation: 1,
                                                  foregroundColor: Colors.blue,
                                                  backgroundColor: Colors.blue,
                                                  onPressed: _editColumnH,
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(10.0),
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      'Edit column',
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        selectedColumn.isEmpty||tableColumns[0]['fn']==selectedColumn||tableColumns[1]['fn']==selectedColumn?const SizedBox.shrink():Column(
                                          children: [
                                            IconButton(onPressed: (){
                                              setState(() {
                                                ascending=!ascending;
                                              });
                                              _sort();
                                            }, icon:ascending?const Icon(Icons.arrow_downward_outlined,color: Colors.black,size: 25,):const Icon(Icons.arrow_upward_outlined,color: Colors.black,size: 25,)),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 5),
                                              child: IconButton(onPressed: _removeColumn, icon: const Icon(Icons.delete_forever)),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              child: TextFormField(
                                                controller: vc,
                                                validator: (value){
                                                  if(value!.length>10){
                                                    return "Max length exceeded";
                                                  }else{
                                                    return null;
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                  const EdgeInsets.only(left: 5, bottom: 1, top: 1),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  labelText: 'Cell value',
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Container(
                                                height: 35,
                                                width: MediaQuery.of(context).size.width * 0.25,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(50),
                                                  shape: BoxShape.rectangle,
                                                ),
                                                child: FloatingActionButton(
                                                  elevation: 1,
                                                  foregroundColor: Colors.blue,
                                                  backgroundColor: Colors.blue,
                                                  onPressed: _editColumnV,
                                                  shape: const RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(10.0),
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      'Edit cell',
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        "${tableColumns[1]['fn']} Actions",
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          height: 35,
                                          width: MediaQuery.of(context).size.width * 0.3,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(50),
                                            shape: BoxShape.rectangle,
                                          ),
                                          child: FloatingActionButton(
                                            elevation: 1,
                                            foregroundColor: Colors.blue,
                                            backgroundColor: Colors.blue,
                                            onPressed:(){
                                              if(formKey.currentState!.validate()){
                                                updateTable();
                                              }},
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                            ),
                                            child:  const Center(
                                              child: Text(
                                                'Update Table',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        CustomNameAvatar(userId:id,radius: 16, style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.normal,
                                        ), maxsize: 70,cloadingname: '${tableColumns[1]['fn']}',),
                                        Container(
                                          height: 35,
                                          width: MediaQuery.of(context).size.width * 0.3,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(50),
                                            shape: BoxShape.rectangle,
                                          ),
                                          child: FloatingActionButton(
                                            elevation: 1,
                                            foregroundColor: Colors.blue,
                                            backgroundColor: Colors.blue,
                                            onPressed: _removeRow,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                            ),
                                            child:  Center(
                                              child: Text(
                                                'remove ${tableColumns[1]['fn']}',
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),];},
                body:  isLoading||dRows.isEmpty? const Center(child: CircularProgressIndicator()):Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Center(child: Text('Teams table',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),)),
                        DataTable(
                            columnSpacing: MediaQuery.of(context).size.width*0.05,
                            columns: tableColumns
                                .map((d) => DataColumn(
                                label: InkWell(
                                  onTap: () {
                                    setState(() {
                                      ec.text = d['fn'];
                                      selectedColumn = d['fn'];
                                      vc.text="";
                                    });
                                  },
                                  child: SizedBox(
                                    height: 30,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(d['fn']),
                                    ),
                                  ),
                                )))
                                .toList(),
                            rows: dRows.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, dynamic> d = entry.value;
                              return DataRow(cells: [
                                DataCell(Text('${index + 1}')),
                                ...tableColumns
                                    .where(
                                        (col) => col['fn'] != tableColumns[0]['fn'])
                                    .map((col) {
                                  String columnName = col['fn'];
                                  int i = tableColumns.indexOf(col);
                                  return DataCell(
                                    i == 1
                                        ? InkWell(
                                      onTap: () {
                                        setState(() {
                                          ec.text = columnName;
                                          club.text=d[columnName];
                                          selectedColumn = columnName;
                                          id = d[tableColumns[1]['fn']];
                                        });
                                      },
                                      child: CustomNameAvatar(userId:d[columnName] ?? '',radius: 16, style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.normal,
                                      ), maxsize: 70,),
                                    )
                                        : InkWell(
                                      onTap: () {
                                        setState(() {
                                          vc.text = d[columnName];
                                          ec.text = columnName;
                                          selectedColumn = columnName;
                                          id = d[tableColumns[1]['fn']];
                                        });
                                      },
                                      child: SizedBox(
                                          height: 30,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: Text(d[columnName] ?? ''),
                                          )),
                                    ),
                                  );
                                }),
                              ]);
                            }).toList()
                        ),
                        const SizedBox(height: 120,)
                      ],
                    ),
                  ),
                )
              )),
          Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                child: IconButton(onPressed: (){
                  if(mdown){
                    controller.jumpTo(controller.position.maxScrollExtent);
                    setState(() {
                      mdown=false;
                    });
                  }else{
                    controller.jumpTo(0.0);
                    setState(() {
                      mdown=true;
                    });
                  }
                },icon:Icon(mdown? Icons.arrow_downward_outlined:Icons.arrow_upward_outlined,color: Colors.black,),
                ),
              ))
        ],
      ));
  }
  Future<Uint8List> generatePDF() async {
    final pdf = pw.Document();
    final tableHeaders = data.first;
    final tableData = data.sublist(1);
    pw.MemoryImage? limage;
    if (profileimage.isNotEmpty) {
      final response = await http.get(Uri.parse(profileimage));
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
                username,
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
class CustomNameAvatar extends StatefulWidget {
  String userId;
  double radius;
  TextStyle style;
  double maxsize;
  Person? user;
  bool click;
  String cloadingname;
  CustomNameAvatar({super.key,
    required this.userId,
    required this.style,
    required this.radius,
    required this.maxsize,
    this.user,
    this.click=false,
    this.cloadingname="loading...."
  });

  @override
  State<CustomNameAvatar> createState() => _CustomNameAvatarState();
}

class _CustomNameAvatarState extends State<CustomNameAvatar> {
  FirebaseFirestore firestore=FirebaseFirestore.instance;
  @override
  void initState(){
    super.initState();
    setState(() {
    name=widget.cloadingname;
    });
    if(widget.userId.isNotEmpty) {
      getData();
    }
  }

  @override
  void didUpdateWidget(covariant CustomNameAvatar oldWidget) {
    if (oldWidget.userId != widget.userId) {
      setState(() {
        name=widget.cloadingname;
      });
      if(widget.userId.isNotEmpty) {
        getData();
      }
    }
    super.didUpdateWidget(oldWidget);
  }
  String url='';
  String name='';
  String collectionName='';
  String location="";
  void getData()async{
    UsersData? appUsage = await DatabaseHelper2Users.instance.getUser(widget.userId);
    if (appUsage != null) {
      setState(() {
        url=appUsage.user.url;
         name =appUsage.user.name;
       collectionName=appUsage.user.collectionName;
       location=appUsage.user.location;
      });

      if(url.isEmpty){
        await getUserData();
        if(widget.userId.isNotEmpty){
        await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
            user: Person(
              name: name,
              userId: widget.userId,
              location: location,
              collectionName: collectionName,
              url: url,
            )
        ));
      }
    }}else{
      await getUserData();
      if(widget.userId.isNotEmpty){
      await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
          user: Person(
            name: name,
            userId: widget.userId,
            location: location,
            collectionName: collectionName,
            url: url,
          )
      ));
    }}
  }
  Future<void>getUserData()async{
    try {
      QuerySnapshot querySnapshotA = await firestore
          .collection('Fans')
          .where('Fanid', isEqualTo: widget.userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotB = await firestore
          .collection('Professionals')
          .where('profeid', isEqualTo: widget.userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotC = await firestore
          .collection('Clubs')
          .where('Clubid', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (querySnapshotA.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotA.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Fan';
          name = data['username'];
          url= data['profileimage'];
          location=data['location'];
        });
      } else if (querySnapshotB.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotB.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Professional';
          name = data['Stagename'];
          url= data['profileimage'];
          location=data['Location'];
        });
      } else if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Club';
          name = data['Clubname'];
          url= data['profileimage'];
          location=data['Location'];
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    if(widget.click){
    return InkWell(
      onTap: () {
        Navigator.push(context,  MaterialPageRoute(
            builder: (context){
              if(collectionName=='Club'){
                return AccountclubViewer(user: Person(name: name, url: url, collectionName: collectionName, userId: widget.userId), index: 0);
              }else if(collectionName=='Professional'){
                return AccountprofilePviewer(user:Person(name: name, url: url, collectionName: collectionName, userId: widget.userId), index: 0);
              }else{
                return Accountfanviewer(user:Person(name: name, url: url, collectionName: collectionName, userId: widget.userId), index: 0);
              }
            }
        ),);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomAvatar(imageurl: url, radius:widget.radius),
          CustomName(username: name, maxsize: widget.maxsize, style: widget.style)
        ],
      ),
    );
  }else{
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomAvatar(imageurl: url, radius:widget.radius),
          CustomName(username: name, maxsize: widget.maxsize, style: widget.style)
        ],
      );
    }
    }
}



class Status1 extends StatefulWidget {
   String status;
  Status1({super.key, required this.status});

  @override
  State<Status1> createState() => _Status1State();
}

class _Status1State extends State<Status1> {
  bool isaccepted = false;
  String state = '1';
  String state1 = '0';
  @override
  void didUpdateWidget(covariant Status1 oldWidget) {
    if (oldWidget.status!= widget.status) {
      setState((){
        widget.status=oldWidget.status;
      });

    }
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    if (widget.status == state) {
      return const Icon(Icons.check_circle_outline, color: Colors.blue,);
    } else if (widget.status == state1) {
      return const Text('declined');
    } else {
      return const Text('pending');
    }
  }
}




