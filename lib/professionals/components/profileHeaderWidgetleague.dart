import 'package:fans_arena/fans/data/notificationsmodel.dart';
import 'package:fans_arena/professionals/screens/accountprofilepviewer.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../clubs/data/lineup.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../clubs/screens/clubteamtable.dart';
import '../../fans/bloc/accountchecker6.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/data/usermodel.dart';
import '../../fans/screens/accountfanviewer.dart';
import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

class CommentsCount0 extends StatelessWidget {
  String leagueId;
  String year;
  CommentsCount0({super.key, required this.leagueId,required this.year});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Leagues')
              .doc(leagueId)
              .collection('year')
              .doc(year)
              .collection('comments')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(height: 0, width: 0,);
            } else {
              final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!
                  .docs;
              int totalLikes = 0;
              for (final likeDocument in likeDocuments) {
                final likesArray = likeDocument['comments'] as List<dynamic>;
                totalLikes = likesArray.length;
              }
              if(totalLikes>999){
                return Text('${totalLikes/1000}K');
              }else if(totalLikes>999999){
                return Text('${totalLikes/1000000}M');
              }else if(totalLikes>999999999){
                return Text('${totalLikes/1000000000}B');
              } else {
                return Text(
                  '$totalLikes',
                );
              }
            }
          }),
    );
  }
}

class ScorersCount extends StatelessWidget {
  String leagueId;
  String year;
  ScorersCount({super.key,required this.leagueId,required this.year});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Leagues')
              .doc(leagueId)
              .collection('year')
              .doc(year)
              .collection('topscorers')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(height: 0, width: 0,);
            } else {
              final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!
                  .docs;
              int totalLikes = 0;
              for (final likeDocument in likeDocuments) {
                final likesArray = likeDocument['scorers'] as List<dynamic>;
                totalLikes = likesArray.length;
              }
              if(totalLikes>999){
                return Text('${totalLikes/1000}K');
              }else if(totalLikes>999999){
                return Text('${totalLikes/1000000}M');
              }else if(totalLikes>999999999){
                return Text('${totalLikes/1000000000}B');
              } else {
                return Text(
                  '$totalLikes',
                );
              }
            }
          }),
    );
  }
}


class Matchecount extends StatelessWidget {
  final String leagueId;
  final String year;
  const Matchecount({super.key,required this.leagueId,required this.year});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Leagues')
              .doc(leagueId)
              .collection('year')
              .doc(year)
              .collection('clubs')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(height: 0, width: 0,);
            } else {
              final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!
                  .docs;
              int totalLikes = 0;
              for (final likeDocument in likeDocuments) {
                final likesArray = likeDocument['clubs'] as List<dynamic>;
                totalLikes = likesArray.length;
              }
              if(totalLikes>999){
                return Text('${totalLikes/1000}K');
              }else if(totalLikes>999999){
                return Text('${totalLikes/1000000}M');
              }else if(totalLikes>999999999){
                return Text('${totalLikes/1000000000}B');
              } else {
                return Text(
                  '$totalLikes',
                );
              }

            }
          }),
    );
  }
}
class Matchecount1 extends StatelessWidget {
  final String leagueId;
  final String year;
  const Matchecount1({super.key,required this.leagueId,required this.year});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Leagues')
              .doc(leagueId)
              .collection('year')
              .doc(year)
              .collection('leaguematches')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(height: 0, width: 0,);
            } else {
              final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!
                  .docs;
              int totalLikes = 0;
              for (final likeDocument in likeDocuments) {
                final likesArray = likeDocument['matches'] as List<dynamic>;
                totalLikes = likesArray.length;
              }
              if(totalLikes>999){
                return Text('${totalLikes/1000}K');
              }else if(totalLikes>999999){
                return Text('${totalLikes/1000000}M');
              }else if(totalLikes>999999999){
                return Text('${totalLikes/1000000000}B');
              } else {
                return Text(
                  '$totalLikes',
                );
              }

            }
          }),
    );
  }
}


class TopscorerGV extends StatefulWidget {
  String leagueId;
  String year;
  String leaguename;
  String image;
  TopscorerGV({super.key,
    required this.leagueId,
    required this.year,
    required this.leaguename,
    required this.image});

  @override
  State<TopscorerGV> createState() => _TopscorerGVState();
}

class _TopscorerGVState extends State<TopscorerGV> {
  bool ascending=false;


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
    final List<dynamic> likesArray = document['scorersTable'];
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
        .collection('topscorers')
        .get();
    final List<QueryDocumentSnapshot> likeDocuments = snapshot.docs;
    List<Map<String, dynamic>> allLikes = [];
    for (final document in likeDocuments) {
      docIds.add(document.id);
      final List<dynamic> likesArray = document['scorers'];
      allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
    }
    setState(() {
      dRows=allLikes;//.where((element) => element['status']=='1').toList();
      isLoading=false;
    });
  }
  String selectedColumn = '';
  String id = '';
  bool isLoading=true;
  List<Map<String, dynamic>> tableColumns = [
    {'fn':'Rank'},
    {'fn':'Player'},
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
      if(url.isEmpty){
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
    }
    navigate();
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

  Future<void> _add() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          height: 80,
          child: Column(
            children: [
              CircularProgressIndicator(),
              Text('Generating PDF..')
            ],
          ),
        ),
      ),
    );

    try {
      List<List<String>> data1 = [];
      List<String> Cheadings = [];
      List<List<String>> rows = [];
      if (tableColumns.isEmpty) {
        throw Exception("tableColumns is empty.");
      }
      for (var cH in tableColumns) {
        String ch = cH['fn'];
        Cheadings.add(ch);
      }
      if (dRows.isEmpty) {
        throw Exception("dRows is empty.");
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
            UsersData? appUsage = await DatabaseHelper2Users.instance.getUser(rw[cH['fn']]);
            if (appUsage != null) {
              // row.add(appUsage.user.url);
              row.add(appUsage.user.name);
            } else {
              row.add("No name");
            }
          } else if (i == 2) {
            QuerySnapshot sn = await FirebaseFirestore.instance
                .collection("Professionals")
                .doc(rw[tableColumns[1]['fn']])
                .collection('club')
                .get();
            if (sn.docs.isEmpty) {
              row.add("No club");
            } else {
              final doc = sn.docs[0];
              UsersData? appUsage = await DatabaseHelper2Users.instance.getUser(doc.id);
              if (appUsage != null) {
                // row.add(appUsage.user.url);
                row.add(appUsage.user.name);
              } else {
                row.add("No club");
              }
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
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(e.toString()),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: const Text("League Top Scorers",style: TextStyle(color: Colors.black),),
          actions: [
            IconButton(
          icon: Icon(Icons.print),
          onPressed: ()async{
            await _add();
            generateAndPrintPDF();
          },
        ),],),
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
                                      selectedColumn.isEmpty||tableColumns[0]['fn']==selectedColumn||tableColumns[1]['fn']==selectedColumn||tableColumns[2]['fn']==selectedColumn?const SizedBox.shrink():InkWell(onTap: (){
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
                      columnSpacing: MediaQuery.of(context).size.width*0.08,
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
                            if(i==1){
                              return DataCell(InkWell(
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
                              );
                            }else if(i==2){
                              return DataCell(PlayersClub(userId: d[tableColumns[1]['fn']]));
                            }else{
                              return DataCell(InkWell(
                                onTap: () {
                                  setState(() {
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
                              ),);
                            }
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
              pw.Text("LEAGUE SCORER'S TABLE", style: pw.TextStyle(
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

class Topscorertable extends StatefulWidget {
  String userId;
  String leagueId;
  String year;
  String leaguename;
  String image;
  Topscorertable({super.key,
    required this.userId,
    required this.leagueId,
    required this.year,
    required this.image,
    required this.leaguename
  });

  @override
  State<Topscorertable> createState() => _TopscorertableState();
}

class _TopscorertableState extends State<Topscorertable> {
  String userId = '';
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
    getFnData();
    getClubData();
    _getCurrentUser();
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
    final List<dynamic> likesArray = document['scorersTable'];
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
        .collection('topscorers')
        .get();
    final List<QueryDocumentSnapshot> likeDocuments = snapshot.docs;
    List<Map<String, dynamic>> allLikes = [];
    for (final document in likeDocuments) {
      docIds.add(document.id);
      final List<dynamic> likesArray = document['scorers'];
      allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
    }
    setState(() {
      dRows=allLikes;
      isLoading=false;
    });
  }
  void _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }
  bool isLoading=true;
  List<Map<String, dynamic>> tableColumns = [
    {'fn':'Rank'},
    {'fn':'Player'},
  ];
  List<Map<String, dynamic>> dRows = [];
  bool set=false;

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
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('Leagues').doc(widget.leagueId).collection(
        'year').doc(widget.year).update({
      'scorersTable': tableColumns,
    });
    for(var docid in docIds){
      await firestore.collection('Leagues').doc(widget.leagueId).collection(
          'year').doc(widget.year).collection("topscorers").doc(docid).update({
        'scorers': dRows,
      }); Navigator.of(context,rootNavigator: true).pop();
      await Future.delayed(Duration(seconds: 1));
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: SizedBox(
            height: 80,
            child: Text('Table Updated'),
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
  final formKey=GlobalKey<FormState>();
  ScrollController controller=ScrollController();
  bool mdown=true;

  List<List<String>> data = [];

  Future<void> _add() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          height: 80,
          child: Column(
            children: [
              CircularProgressIndicator(),
              Text('Generating PDF..')
            ],
          ),
        ),
      ),
    );

    try {
      List<List<String>> data1 = [];
      List<String> Cheadings = [];
      List<List<String>> rows = [];
      if (tableColumns.isEmpty) {
        throw Exception("tableColumns is empty.");
      }
      for (var cH in tableColumns) {
        String ch = cH['fn'];
        Cheadings.add(ch);
      }
      if (dRows.isEmpty) {
        throw Exception("dRows is empty.");
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
            UsersData? appUsage = await DatabaseHelper2Users.instance.getUser(rw[cH['fn']]);
            if (appUsage != null) {
              // row.add(appUsage.user.url);
              row.add(appUsage.user.name);
            } else {
              row.add("No name");
            }
          } else if (i == 2) {
            QuerySnapshot sn = await FirebaseFirestore.instance
                .collection("Professionals")
                .doc(rw[tableColumns[1]['fn']])
                .collection('club')
                .get();
            if (sn.docs.isEmpty) {
              row.add("No club");
            } else {
              final doc = sn.docs[0];
              UsersData? appUsage = await DatabaseHelper2Users.instance.getUser(doc.id);
              if (appUsage != null) {
                // row.add(appUsage.user.url);
                row.add(appUsage.user.name);
              } else {
                row.add("No club");
              }
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
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text("League Top Scorers",style: TextStyle(color: Colors.black),),
        actions: [
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 80,
              child: IconButton(onPressed: (){
                setState(() {
                  set=!set;
                });
              }, icon: Icon(set?Icons.close:Icons.add,color: Colors.black,)),
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
                    child:  AnimatedContainer(
                        width: MediaQuery.of(context).size.width,
                        height:set? 235:0,
                        duration: const Duration(milliseconds: 750),
                        child: HeaderWidgetTopS(leagueId: widget.leagueId,year:widget.year, dRows: dRows, tableColumns: tableColumns,)),
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
                                                const EdgeInsets.only(left: 5, bottom: 1, top: 1),
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
                                                foregroundColor: Colors.blue,
                                                backgroundColor: Colors.blue,
                                                elevation: 1,
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
                                                const EdgeInsets.only(left: 5, bottom: 1, top: 1),
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
                                                foregroundColor: Colors.blue,
                                                backgroundColor: Colors.blue,
                                                elevation: 1,
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
                                      selectedColumn.isEmpty||tableColumns[0]['fn']==selectedColumn||tableColumns[1]['fn']==selectedColumn||tableColumns[2]['fn']==selectedColumn?const SizedBox.shrink():Column(
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
                                                foregroundColor: Colors.blue,
                                                backgroundColor: Colors.blue,
                                                elevation: 1,
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
                                          foregroundColor: Colors.blue,
                                          backgroundColor: Colors.blue,
                                          elevation: 1,
                                          onPressed:(){
                                            if(formKey.currentState!.validate()||dRows.isEmpty){
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
              body: Column(
                children: [
                  const Text(
                    "Table",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  isLoading||dRows.isEmpty? const Center(child: CircularProgressIndicator()):SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
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
                                .where((col) => col['fn'] != tableColumns[0]['fn'])
                                .map((col) {
                              String columnName = col['fn'];
                              int i = tableColumns.indexOf(col);
                               if(i==1){
                              return DataCell(InkWell(
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
                              );
                            }else if(i==2){
                                 return DataCell(PlayersClub(userId: d[tableColumns[1]['fn']]));
                               }else{
                                 return DataCell(InkWell(
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
                                 ),);
                               }}),
                          ]);
                        }).toList()
                    ),
                  ),
                  const SizedBox(height: 120,)
                ],
              ),
            ),
          ),
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
              pw.Text("LEAGUE SCORER'S TABLE", style: pw.TextStyle(
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


class PlayersClub extends StatefulWidget {
  String userId;
  PlayersClub({super.key,required this.userId});

  @override
  State<PlayersClub> createState() => _PlayersClubState();
}

class _PlayersClubState extends State<PlayersClub> {
late Stream<QuerySnapshot> data;
  @override
  void initState() {
    super.initState();
   data=FirebaseFirestore.instance.collection('Professionals').doc(widget.userId).collection('club').snapshots();
  }
@override
void didUpdateWidget(covariant PlayersClub oldWidget) {
  if (oldWidget.userId != widget.userId) {
    setState(() {
      data=FirebaseFirestore.instance.collection('Professionals').doc(widget.userId).collection('club').snapshots();
    });
  }
  super.didUpdateWidget(oldWidget);
}
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream:data,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: Text("loading club.."));
          }else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No club"));
          } else {
            final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!.docs;
            String user='';
            for (final document in likeDocuments) {
              user= document.id;
            }
            return  CustomNameAvatar(userId:user,radius: 16, style: const TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ), maxsize: 70,click: true,);
          }
        });
  }
}

class HeaderWidgetTopS extends StatefulWidget {
  String leagueId;
  String year;
  List<Map<String,dynamic>>tableColumns;
  List<Map<String,dynamic>>dRows;
  HeaderWidgetTopS({super.key,
    required this.leagueId,
    required this.year,
    required this.dRows,
    required this.tableColumns,
    });

  @override
  State<HeaderWidgetTopS> createState() => _HeaderWidgetTopSState();
}

class _HeaderWidgetTopSState extends State<HeaderWidgetTopS> {
  final TextEditingController _controller = TextEditingController();
  bool _showCloseIcon = false;

  String y='';
  SearchService5 search=SearchService5();
  String _searchQuery = '';
  double radius=18;
  @override
  Widget build(BuildContext context) {
    return
      Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: 235,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: SizedBox(
                    height:37,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.71,
                    child: TextFormField(
                      scrollPadding: const EdgeInsets.only(left: 10),
                      textAlign: TextAlign.justify,
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: Colors.black,
                      controller: _controller,
                      onChanged: (value) {
                        setState(() {
                          _showCloseIcon = value.isNotEmpty;
                          _searchQuery=value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(width: 1, color: Colors.black),
                        ),
                        focusedBorder:  OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(width: 1, color: Colors.black),
                        ),
                        filled: true,
                        hintStyle: const TextStyle(color: Colors.black,
                          fontSize: 14, fontWeight: FontWeight.normal,),
                        fillColor: Colors.white70,
                        suffixIcon: _showCloseIcon ? IconButton(
                          icon: const Icon(Icons.close,color: Colors.black,),
                          onPressed: () {
                            setState(() {
                              _controller.clear();
                              _showCloseIcon = false;
                              _searchQuery=y;
                            });
                          },
                        ) : null,
                        hintText: 'Search',
                      ),
                    )),
              ),
            ),
            StreamBuilder<Set<UserModelP>>(
              stream: search.getUser(_searchQuery),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator()),
                  );
                }
                Set<UserModelP> userList1 = snapshot.data!;
                List<UserModelP> userList =List.from(userList1);
                return Expanded(
                  child: ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      UserModelP user = userList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: SizedBox(
                          height: 40,
                          child: ListTile(
                              leading:CustomAvatar(radius: radius, imageurl:user.url),
                              title:  InkWell(
                                onTap: () {
                                  Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AccountprofilePviewer(user:Person(
                                                userId: user.userId,
                                                name: user.stagename,
                                                url: user.url,
                                                collectionName:'Professional'
                                            ),index:0)
                                    ),
                                  );
                                },
                                child:    Padding(
                                  padding: const EdgeInsets
                                      .only(left: 5),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 10.0,
                                      maxWidth: 160.0,
                                    ),
                                    color: Colors.transparent,
                                    height: 38.0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          color: Colors.transparent,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                minWidth: 10.0,
                                                maxWidth: 140.0,
                                              ),
                                              child: Text(
                                                user.stagename,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: Align(
                                            alignment: AlignmentDirectional.centerStart,
                                            child:  SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:  Accountchecker6(user:Person(
                                                    userId: user.userId,
                                                    name: user.stagename,
                                                    url: user.url,
                                                    collectionName:'Professional'
                                                ),)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              trailing: SizedBox(
                                  width: 90,
                                  child: Addbtn(userId: user.userId, leagueId: widget.leagueId, year:widget.year, tableColumns: widget.tableColumns, dRows: widget.dRows,))
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      );
  }
}




class Addbtn extends StatefulWidget {
  String leagueId;
  String userId;
  String year;
  List<Map<String,dynamic>>tableColumns;
  List<Map<String,dynamic>>dRows;
  Addbtn({super.key,
    required this.userId,
    required this.leagueId,
    required this.year,
    required this.tableColumns,
    required this.dRows});

  @override
  State<Addbtn> createState() => _AddbtnState();
}

class _AddbtnState extends State<Addbtn> {
  bool isadded=false;
  @override
  void initState() {
    super.initState();
    _checkUseristeam();
    setState(() {
      if(widget.tableColumns.isEmpty) {
        widget.tableColumns=[
          {'fn':'Rank'},
          {'fn':'Player'},
          {'fn':'Club'},
        ];
      }
    });
  }
  String message10='added you to the league top scorers table';
  void _checkUseristeam(){
    bool added=widget.dRows.any((element) => element[widget.tableColumns[1]['fn']]==widget.userId);
    setState(() {
      isadded = added;
    });
  }
  DateTime now=DateTime.now();
  Future<void> deleteTeamMemeber() async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.leagueId)
        .collection('year')
        .doc(widget.year)
        .collection('topscorers');
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    for (final document in documents) {
      final List<dynamic> likesArray = document['scorers'];
      final index = likesArray.indexWhere((like) => like[widget.tableColumns[1]['fn']] == widget.userId);
      if (index != -1) {
        likesArray.removeAt(index);
        await document.reference.update({'scorers': likesArray});
        setState(() {
          isadded=false;
        });
        Navigator.of(context, rootNavigator: true).pop();
        return;
      }
    }
  }
  List<Map<String, dynamic>> dRows = [];
  void _addRow() {
    setState(() {
      if (widget.userId.isNotEmpty) {
        Map<String, dynamic> data = {};
        for (var d in widget.tableColumns) {
          int i = widget.tableColumns.indexOf(d);
          if (i == 1) {
            data[d['fn']] = widget.userId;
          } else if (i > 1) {
            data[d['fn']] = '0';
          } else {
            data[d['fn']] = '';
          }
        }
        dRows.add(data);
        String newColumnName = "createdAt";
        String newColumnName1 = "status";
        if (newColumnName.isNotEmpty) {
          for (var d in dRows) {
            d[newColumnName] = Timestamp.now();
            d[newColumnName1] = "";
          }
        }
      }
    });
    addClub();
  }
  Future<void> addClub() async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.leagueId)
        .collection('year')
        .doc(widget.year)
        .collection('topscorers');
    if(widget.tableColumns.isEmpty) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('Leagues').doc(widget.leagueId).collection(
          'year').doc(widget.year).update({
        'scorersTable': widget.tableColumns,
      });
    }
    final bool userLiked = widget.dRows.any((element) => element[widget.tableColumns[1]['fn']]==widget.userId);
    if (userLiked) {
      return;
    }
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    if (documents.isNotEmpty) {
      final DocumentSnapshot latestDoc = documents.first;
      List<dynamic> likesArray = latestDoc['scorers'];
      if (likesArray.length < 500) {
        likesArray.addAll(dRows);
        await latestDoc.reference.update({'scorers': likesArray});
        setState(() {
          isadded=true;
          widget.dRows.addAll(dRows);
        });
        await Sendnotification(from:widget.leagueId, to: widget.userId, message: message10, content: '').sendnotification();
      } else {
        await likesCollection.add({'scorers': dRows});
        setState(() {
          isadded=true;
          widget.dRows.addAll(dRows);
        });
      }
    } else {
      await likesCollection.add({'scorers': dRows});
      setState(() {
        isadded=true;
        widget.dRows.addAll(dRows);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: isadded?OutlinedButton(
        style: OutlinedButton.styleFrom(

            minimumSize: const Size(0, 30),
            side: const BorderSide(
              color: Colors.grey,
            )),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: const Text('Remove player'),
                    content: const Text('Do you want to remove player?'),
                    actions: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              child: const Text('No'),
                              onPressed: () {
                                Navigator.pop(context); // Dismiss the dialog
                              },
                            ),
                            TextButton(
                              onPressed: deleteTeamMemeber,
                              child: const Text('Yes'),)
                          ]),]
                );
              }
          );
        },
        child: const Text(
          'Added', style: TextStyle(color: Colors.black),),
      ):OutlinedButton(
        style: OutlinedButton.styleFrom(

            minimumSize: const Size(0, 30),
            side: const BorderSide(
              color: Colors.grey,
            )),
        onPressed: _addRow,
        child: const Text(
          'Add', style: TextStyle(color: Colors.black),),
      ),
    );
  }
}

