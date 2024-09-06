import 'package:fans_arena/fans/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../clubs/data/lineup.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../clubs/screens/clubteamtable.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../data/newsfeedmodel.dart';
import 'accountfanviewer.dart';
import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
class Leaguetable extends StatefulWidget {
  String leagueId;
  String year;
  String leaguename;
  String image;
  Leaguetable({super.key,
    required this.leagueId,
    required this.year,
    required this.leaguename,
    required this.image});
  @override
  State<Leaguetable> createState() => _LeaguetableState();
}

class _LeaguetableState extends State<Leaguetable> {

  String userId='';
  final DateTime _startTime = DateTime.now();
  @override
  void dispose(){
    Engagement().engagement('LeagueTableV',_startTime,widget.leagueId);
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    getFnData();
    getClubData();
  }
  void getFnData()async{
    DocumentSnapshot snapshot= await FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.leagueId)
        .collection('year')
        .doc(widget.year)
        .get();
    var document= snapshot.data() as Map<String,dynamic>;
    List<Map<String, dynamic>> allLikes = [];
    final List<dynamic> likesArray = document['leagueTable'];
    allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
    setState(() {
      tableColumns=allLikes;
    });
  }
  Set<String>docIds={};
  void getClubData()async{
    QuerySnapshot snapshot= await FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.leagueId)
        .collection('year')
        .doc(widget.year)
        .collection('clubs')
        .get();
    final List<QueryDocumentSnapshot> likeDocuments = snapshot.docs;
    List<Map<String, dynamic>> allLikes = [];
    for (final document in likeDocuments) {
      docIds.add(document.id);
      final List<dynamic> likesArray = document['clubs'];
      allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
    }
    setState(() {
      dRows=allLikes;//.where((element) => element['status']=='1').toList();
      isLoading=false;
    });
  }
  String selectedColumn = '';
  String id = '';
  bool ascending=true;
  bool isLoading=true;
  List<Map<String, dynamic>> tableColumns = [
    {'fn':'Rank'},
    {'fn':'Club'},
  ];
  List<Map<String, dynamic>> dRows = [];
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
  ScrollController controller=ScrollController();
  String url='';
  String name='';
  String collectionName='';
  String location="";
  void _view()async{
    UsersData? appUsage = await DatabaseHelper2Users.instance.getUser(id);
    if (appUsage != null) {
      setState(() {
        url=appUsage.user.url;
        name =appUsage.user.name;
        collectionName=appUsage.user.collectionName;
        location=appUsage.user.location;
      });
      navigate();
    }else{
      await getUserData();
      await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
          user: Person(
            name: name,
            userId: id,
            location: location,
            collectionName: collectionName,
            url: url,
          )
      ));
      navigate();
    }
  }
  void navigate(){
    Navigator.push(context,  MaterialPageRoute(
        builder: (context){
          if(collectionName=='Club'){
            return AccountclubViewer(user: Person(name: name, url: url, collectionName: collectionName, userId: id), index: 0);
          }else if(collectionName=='Professional'){
            return AccountprofilePviewer(user:Person(name: name, url: url, collectionName: collectionName, userId: id), index: 0);
          }else{
            return Accountfanviewer(user:Person(name: name, url: url, collectionName: collectionName, userId: id), index: 0);
          }
        }
    ),);
  }
  FirebaseFirestore firestore=FirebaseFirestore.instance;
  Future<void>getUserData()async{
    try {
      QuerySnapshot querySnapshotA = await firestore
          .collection('Fans')
          .where('Fanid', isEqualTo: id)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotB = await firestore
          .collection('Professionals')
          .where('profeid', isEqualTo: id)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotC = await firestore
          .collection('Clubs')
          .where('Clubid', isEqualTo: id)
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
              //row.add(appUsage.user.url);
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
          title: const Text("League Table",style: TextStyle(color: Colors.black),),
        actions: [
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
          child: NestedScrollView(
            controller: controller,
            headerSliverBuilder: (context, _) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                      children: [
                        const Text(
                          'Table Options',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 120,
                          margin: const EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 1.5, color: Colors.grey[400]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          width: 100,
                                          child: Text(selectedColumn)
                                      ),
                                      selectedColumn.isEmpty||tableColumns[0]['fn']==selectedColumn||tableColumns[1]['fn']==selectedColumn?const SizedBox.shrink():InkWell(onTap: (){
                                        setState(() {
                                          ascending=!ascending;
                                        });
                                        _sort();
                                      }, child:ascending?const Icon(Icons.arrow_downward_outlined,color: Colors.black,size: 25,):const Icon(Icons.arrow_upward_outlined,color: Colors.black,size: 25,)),
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
                                          onPressed: _view,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),
                                          child:  Center(
                                            child: Text(
                                              'view ${tableColumns[1]['fn']}',
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ]
                            ),
                          ),
                        )]
                  ),
                ),];},
            body: Column(
              children: [
                const Text(
                  "Table",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                isLoading||dRows.isEmpty? const Center(child: CircularProgressIndicator()):SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                      columnSpacing: MediaQuery.of(context).size.width*0.03,
                      columns: tableColumns
                          .map((d) => DataColumn(
                          label: InkWell(
                            onTap: () {
                              setState(() {
                                selectedColumn = d['fn'];
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
                  ),
                ),
              ],
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
    if (widget.image.isNotEmpty) {
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
              pw.Text("LEAGUE TABLE", style: pw.TextStyle(
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
                widget.leaguename,
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


