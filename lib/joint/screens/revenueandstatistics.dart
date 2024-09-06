import 'package:fans_arena/appid.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../fans/screens/newsfeed.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class RevenueInsights extends StatefulWidget {
  const RevenueInsights({super.key});

  @override
  State<RevenueInsights> createState() => _RevenueInsightsState();
}

class _RevenueInsightsState extends State<RevenueInsights> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: const Text("Revenue & Insights", style: TextStyle(color: Colors.black),),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 5),
                child: InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const EventStatistics()));
                  },
                  child: Container(
                      height: 60,
                      color: Colors.grey[200],
                      width: MediaQuery.of(context).size.width,
                      child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Event & Match Insights',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          ))),
                )),
            Padding(
                padding: const EdgeInsets.only(top: 5),
                child: InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const Advertisement()));
                  },
                  child: Container(
                      height: 60,
                      color: Colors.grey[200],
                      width: MediaQuery.of(context).size.width,
                      child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Advertisement',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          ))),
                )),
          ],
        ),
      ),
    );
  }
}
class AccountInsights extends StatefulWidget {
  const AccountInsights({super.key});

  @override
  State<AccountInsights> createState() => _AccountInsightsState();
}

class _AccountInsightsState extends State<AccountInsights> {
  @override
  void initState(){
    super.initState();
    getData();
  }
  DateTime date=DateTime.now();

  DateTime? _selectedDate;
  DateTime? _selectedDate1;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.utc(2050),

    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  Future<void> _selectDate1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate1 ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.utc(2050),

    );

    if (picked != null && picked != _selectedDate1) {
      setState(() {
        _selectedDate1 = picked;
      });
    }
  }
bool isLoading=true;
  late List<UserData> userPoints;
  Map<String,dynamic> data={'Fan':"followers","Club":"fans","Professional":"fans"};
  void getData() async {
    setState(() {
      isLoading=true;
    });
    String to="";
    String from="";
    if(_selectedDate==null||_selectedDate1==null) {
      setState(() {
        DateTime now = DateTime.now();
        to = DateTime(now.year, now.month, now.day,).toString();
        from= DateTime(now.year, now.month, now.day - 7,).toString();
      });
    }else{
      setState(() {
      to = DateTime(_selectedDate1!.year, _selectedDate1!.month, _selectedDate1!.day,).toString();
      from= DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day,).toString();
      });
    }
    try {
      userPoints = await DataFetcher().userData(FirebaseAuth.instance.currentUser!.uid,"${collectionNamefor}s",data[collectionNamefor],from,to);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("$e"),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text("Account Insights", style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
      ),
      body: Column(
          children: [
       Text('Monthly ${data[collectionNamefor]} Bar Graph',style: TextStyle(fontWeight: FontWeight.bold),),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              const Text("From:"),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.45,
                height: 38,
                child: TextFormField(
                    onTap: () {
                      _selectDate(context);
                    },
                    readOnly: true,
                    controller: TextEditingController(
                      text: _selectedDate != null
                          ? "${_selectedDate!.toLocal()}".split(' ')[0]
                          : '',
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors
                                .grey),
                        borderRadius: BorderRadius
                            .circular(8),
                      ),
                      hintText: 'fromDate',
                      labelText: 'fromDate',
                    )),
              ),
            ],
          ),
          const SizedBox(width: 20,),
          Column(
            children: [
              const Text("To:"),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.45,
                height: 38,
                child: TextFormField(
                    onTap: () {
                      _selectDate1(context);
                    },
                    readOnly: true,
                    controller: TextEditingController(
                      text: _selectedDate1 != null
                          ? "${_selectedDate1!.toLocal()}".split(' ')[0]
                          : '',
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors
                                .grey),
                        borderRadius: BorderRadius
                            .circular(8),
                      ),
                      hintText: 'toDate',
                      labelText: 'toDate',
                    )),
              ),
            ],
          ),

        ],
      ),
     _selectedDate1!=null||_selectedDate!=null?SizedBox(width: 120,
         child: actions(context)):SizedBox.shrink(),
      const SizedBox(height: 15,),
           isLoading?Center(child: CircularProgressIndicator()):SingleChildScrollView(
             scrollDirection: Axis.horizontal,
             child: Padding(
               padding: const EdgeInsets.all(5.0),
               child: SizedBox(
                         height: 400,
                         width: MediaQuery.of(context).size.width,
                         child: buildGraph(userPoints,data[collectionNamefor],'days')
                         ),
             ),
           ),
           ])
    );
  }
  Widget actions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                minimumSize: const Size(0, 30),
                side: const BorderSide(
                  color: Colors.grey,
                )),
            onPressed: getData,
            child: const Text("fetch Data", style: TextStyle(color: Colors.black)),
          ),
        ),

      ],
    );
  }
  Widget buildGraph(List<UserData> dataMap, String y, String x) {
    List<FlSpot> spots = dataMap.map((match) {
      DateTime dateTime = DateFormat('yyyy-MM-dd').parse(match.date);
      double xValue = dateTime.difference(DateTime(1970, 1, 1)).inDays.toDouble();
      double yValue = match.users.toDouble();
      return FlSpot(xValue, yValue);
    }).toList();

    final lineChartBarData = LineChartBarData(
      color: Colors.blueAccent,
      isStrokeJoinRound: true,
      spots: spots,
      dotData: const FlDotData(
        show: true,
      ),
    );
    final dataPoints = <LineChartBarData>[lineChartBarData];
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: LineChart(
            LineChartData(
              maxY: spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0,
              minY: 0,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    y,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, titleMeta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameSize: 16,
                  axisNameWidget: Text(
                    x,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 25,
                    interval: 1,
                    getTitlesWidget: (value, titleMeta) {
                      DateTime date = DateTime(1970, 1, 1).add(Duration(days: value.toInt()));
                      return Text(
                        DateFormat('MM-dd').format(date),
                        style: const TextStyle(fontSize: 11),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: dataPoints,
            ),
          ),
        ),
      ],
    );
  }
}

class EventStatistics extends StatefulWidget {
  const EventStatistics({super.key});

  @override
  State<EventStatistics> createState() => _EventStatisticsState();
}

class _EventStatisticsState extends State<EventStatistics> {



  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getCurrencyData();
    getData();
    getData1();
  }

  bool isLoading = true;
  bool isLoading1 = true;
  List<MatchData> matchPoints = [];

  void getData() async {
    try {
      matchPoints = await DataFetcher().allMatchData(FirebaseAuth.instance.currentUser!.uid, "Matches");
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("$e"),
        ),
      );
    }
  }

  List<MatchData> eventPoints = [];

  void getData1() async {
    try {
      eventPoints = await DataFetcher().allMatchData(FirebaseAuth.instance.currentUser!.uid, "Events");
      setState(() {
        isLoading1 = false;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("$e"),
        ),
      );
    }
  }

  String country = "Kenya";
  String currency = "USD";

  void getCurrencyData() async {
    List<Map<String, dynamic>> countryData = [];
    DocumentSnapshot documentSnapshot = await firestore.collection("exchangeRates").doc('USD').get();
    if (documentSnapshot.exists) {
      var data = documentSnapshot.data() as Map<String, dynamic>;
      setState(() {
        countryData = List.from(data['countryData']);
        Map<String, dynamic> foundCountry = countryData.firstWhere(
              (element) => element['country'] == country,
          orElse: () => {},
        );
        String c = foundCountry['currency'] ?? "USD";
        exrate = data[c];
        currency = foundCountry['currency'] ?? "USD";
      });
    }
  }

  double cpm = 0.25;
  double exrate = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text("Event & Match Insights", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text('Monthly Matches Graph', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 700,
                    width: MediaQuery.of(context).size.width,
                    child: isLoading ? Center(child: CircularProgressIndicator()) : barGraph(matchPoints, "Match Data", "Day", "Match"),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Monthly Events Graph', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: SizedBox(
                    height: 700,
                    width: MediaQuery.of(context).size.width,
                    child: isLoading1 ? Center(child: CircularProgressIndicator()) : barGraph(eventPoints, "Event Data", "Day", "Event"),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Revenue Graph', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: SizedBox(
                    height: 700,
                    width: MediaQuery.of(context).size.width,
                    child: isLoading1 && isLoading ? Center(child: CircularProgressIndicator()) : barGraph1([...eventPoints,...matchPoints], "Revenue Data", "Day",),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Payment(eventPoints, matchPoints),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget actions(BuildContext context, List<MatchData> data1, List<MatchData> data) {
    double watchhours = data.fold(0, (sum, element) => sum + element.totalWatchhours);
    double watchhours1 = data1.fold(0, (sum, element) => sum + element.totalWatchhours);
    double totalWatchhours = watchhours + watchhours1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              minimumSize: const Size(0, 30),
              side: const BorderSide(color: Colors.grey),
            ),
            onPressed: () {
             // if (totalWatchhours < 400) {
              //  showDialog(context: context, builder: (context) {
              //    return AlertDialog(
                //    title: Text("Not Eligible"),
               //     content: Text("You have not reached the minimum requirement of 400 watch hours"),
               //   );
               // });
             // } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ApplyForMonetisation()));
            //  }
            },
            child: const Text("Apply For Monetization", style: TextStyle(color: Colors.black)),
          ),
        ),
      ],
    );
  }

  Widget actions1(BuildContext context, List<MatchData> data1, List<MatchData> data) {
    double watchhours = data.fold(0, (sum, element) => sum + element.totalWatchhours);
    double watchhours1 = data1.fold(0, (sum, element) => sum + element.totalWatchhours);
    double totalWatchhours = watchhours + watchhours1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              minimumSize: const Size(0, 30),
              side: const BorderSide(color: Colors.grey),
            ),
            onPressed: () {
              // if (totalWatchhours < 400) {
              //  showDialog(context: context, builder: (context) {
              //    return AlertDialog(
              //    title: Text("Not Eligible"),
              //     content: Text("You have not reached the minimum requirement of 400 watch hours"),
              //   );
              // });
              // } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Transactions()));
              //  }
            },
            child: const Text("Transactions", style: TextStyle(color: Colors.black)),
          ),
        ),
      ],
    );
  }
  Widget Payment(List<MatchData> data1, List<MatchData> data) {
    int views = data.fold(0, (sum, element) => sum + element.totalViews);
    int views1 = data1.fold(0, (sum, element) => sum + element.totalViews);
    int totalViews = views + views1;
    double watchhours = data.fold(0, (sum, element) => sum + element.totalWatchhours);
    double watchhours1 = data1.fold(0, (sum, element) => sum + element.totalWatchhours);
    double totalWatchhours = watchhours + watchhours1;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Text("Monetization", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Column(
                children: [
                  Text("Eligibility Status", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(totalWatchhours > 400 ? "Yes" : "No"),
                  SizedBox(height: 2,),
                ],
              ),
            ),
           Padding(
              padding: const EdgeInsets.all(3.0),
              child: Column(
                children: [
                  Text("Progress", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 2,),
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: (totalWatchhours / 400) + 0.6,
                          backgroundColor: Colors.grey,
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "${(60.4 + (totalWatchhours / 400) * 100).toStringAsFixed(1)}%",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Column(
                  children: [
                    Text("This month Watch Hours", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("$totalWatchhours"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Column(
                  children: [
                    Text("Total Watch Hours", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("$totalWatchhours"),
                  ],
                ),
              ),
          ],),
          SizedBox(height: 5),
          Text("Earnings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 5),
          Wrap(children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Column(
                children: [
                  Text("CPM", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 1),
                  Text("Charge per 1000 views"),
                  Text("USD $cpm")
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Column(
                children: [
                  Text("Personal details", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 1),
                  Text("Country"),
                  Text("$country")
                ],
              ),
            ),
          ],),
          SizedBox(height: 1),
          Text("Cash-out Amount", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("$currency ${totalViews * cpm * exrate / 1000}"),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50,vertical: 10),
            child: Column(
              children: [
                actions1(context, eventPoints, matchPoints),
                SizedBox(height: 10),
                actions(context, eventPoints, matchPoints),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget barGraph(List<MatchData> data, String y, String x, String event) {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: BarChart(
            BarChartData(
              barGroups: data.map((match) {
                return BarChartGroupData(
                  x: match.day,
                  barRods: [
                    BarChartRodData(
                      toY: match.totalLikes.toDouble(),
                      color: Colors.blue,
                      width: 8,
                    ),
                    BarChartRodData(
                      toY: match.duration.toDouble(),
                      color: Colors.red,
                      width: 8,
                    ),
                    BarChartRodData(
                      toY: match.totalWatchhours,
                      color: Colors.green,
                      width: 8,
                    ),
                    BarChartRodData(
                      toY: match.totalViews.toDouble(),
                      color: Colors.orange,
                      width: 8,
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),
            ),
          ),
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: 10, width: 10, color: Colors.red),
            Text(" duration"),
            SizedBox(width: 20),
            Container(height: 10, width: 10, color: Colors.green),
            Text(" watch hours"),
            SizedBox(width: 20),
            Container(height: 10, width: 10, color: Colors.blue),
            Text(" likes"),
            SizedBox(width: 20),
            Container(height: 10, width: 10, color: Colors.orange),
            Text(" views")
          ],
        ),
        SizedBox(height: 10),
        TextGraphData(data, y, x, event)
      ],
    );
  }
  Widget barGraph1(List<MatchData> data, String y, String x,) {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: BarChart(
            BarChartData(
              barGroups: data.map((match) {
                double revenue= (match.totalViews/1000)*cpm;
                return BarChartGroupData(
                  x: match.day,
                  barRods: [
                    BarChartRodData(
                      toY: match.donations.toDouble(),
                      color: Colors.purple,
                      width: 14,
                    ),
                    BarChartRodData(
                      toY: revenue,
                      color: Colors.yellow,
                      width: 14,
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),
            ),
          ),
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: 10, width: 10, color: Colors.purple),
            Text(" donations"),
            SizedBox(width: 20),
            Container(height: 10, width: 10, color: Colors.yellow),
            Text(" views revenue"),
          ],
        ),
        SizedBox(height: 10),
        TextGraphData1(data)
      ],
    );
  }
  Widget TextGraphData(List<MatchData> dataMap, String y, String x, String event) {
    double watchhours = dataMap.fold(0, (sum, element) => sum + element.totalWatchhours);
    int views = dataMap.fold(0, (sum, element) => sum + element.totalViews);
    int likes = dataMap.fold(0, (sum, element) => sum + element.totalLikes);
    int duration = dataMap.fold(0, (sum, element) => sum + element.duration);
    double average = watchhours / dataMap.length;
    double averageWatchhours = watchhours / views;
    double averageDuration = duration / dataMap.length;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Graph Insights", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 5),
         IntrinsicHeight(
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Column(
                  children: [
                    Text("Likes", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("$likes"),
                  ],
                ),
              ),
               VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
             Padding(
               padding: const EdgeInsets.all(3.0),
               child: Column(
                 children: [
                   Text("Views", style: TextStyle(fontWeight: FontWeight.bold)),
                   Text("$views"),
                 ],
               ),
             ),
               VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
             Padding(
               padding: const EdgeInsets.all(3.0),
               child: Column(
                 children: [
                   Text("Watch hours", style: TextStyle(fontWeight: FontWeight.bold)),
                   Text("$watchhours"),
                 ],
               ),
             ),
               VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
             Padding(
               padding: const EdgeInsets.all(3.0),
               child: Column(
                 children: [
                   Text("Duration", style: TextStyle(fontWeight: FontWeight.bold)),
                   Text("$duration"),
                 ],
               ),
             ),
             ],),
         ),
           Padding(
             padding: const EdgeInsets.all(3.0),
             child: Column(
               children: [
                 Text("Average Watch Hours per View", style: TextStyle(fontWeight: FontWeight.bold)),
                 Text("$averageWatchhours"),
               ],
             ),
           ),
           Padding(
             padding: const EdgeInsets.all(3.0),
             child: Column(
               children: [
                 Text("Average Watch Hours per $event", style: TextStyle(fontWeight: FontWeight.bold)),
                 Text("$average"),
               ],
             ),
           ),
           Padding(
             padding: const EdgeInsets.all(3.0),
             child: Column(
               children: [
                 Text("Average Duration per $event", style: TextStyle(fontWeight: FontWeight.bold)),
                 Text("$averageDuration"),
               ],
             ),
           ),

        ],
      ),
    );
  }

  Widget TextGraphData1(List<MatchData> dataMap) {
    int views = dataMap.fold(0, (sum, element) => sum + element.totalViews);
    double donations = dataMap.fold(0, (sum, element) => sum + element.donations);
    double averageDonations = donations / dataMap.length;
    double viewsRevenue=(views/1000)*cpm;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Graph Insights", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 5),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Column(
                    children: [
                      Text("Donations", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("$donations"),
                    ],
                  ),
                ),
                VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Column(
                    children: [
                      Text("Views revenue", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("$viewsRevenue"),
                    ],
                  ),
                ),
              ],),
          ),
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Column(
              children: [
                Text("Average Donations per Event", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("$averageDonations"),
              ],
            ),
          ),
Padding(
  padding: const EdgeInsets.all(3.0),
  child: Text("Monthly Growth Percentage",style:TextStyle(fontWeight: FontWeight.bold) ,),
)
        ],
      ),
    );
  }
}



class Advertisement extends StatefulWidget {
  const Advertisement({super.key});

  @override
  State<Advertisement> createState() => _AdvertisementState();
}

class _AdvertisementState extends State<Advertisement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text("Advertisement", style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
      ),
    );
  }
}




class ApplyForMonetisation extends StatefulWidget {
  const ApplyForMonetisation({super.key});

  @override
  State<ApplyForMonetisation> createState() => _ApplyForMonetisationState();
}

class _ApplyForMonetisationState extends State<ApplyForMonetisation> {
  final _formKey = GlobalKey<FormState>();
  final _mpesaOrAccountNoController = TextEditingController();
  File? _selectedImage;
  File? _selectedPdf;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _mpesaOrAccountNoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickPdf() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // For simplicity, using image picker
    if (pickedFile != null) {
      setState(() {
        _selectedPdf = File(pickedFile.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final mpesaOrAccountNo = _mpesaOrAccountNoController.text;
      // Here you would handle the file upload logic
      print('M-Pesa or Account No: $mpesaOrAccountNo');
      print('Image File Path: ${_selectedImage?.path}');
      print('PDF File Path: ${_selectedPdf?.path}');

      // Clear the form
      _formKey.currentState?.reset();
      setState(() {
        _selectedImage = null;
        _selectedPdf = null;
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text("Apply for Monetization", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Read Terms And Conditions Applying to Monetization'),
              const Text('Apply For Monetization of your Content'),
              const SizedBox(height: 16),
              const Text('Requirements: Payment option => M-Pesa no, Account no, KRA pin Document, passport size photo of account administrator, Copy of National ID'),
              const SizedBox(height: 16),
              const Text('Payment Options'),
              TextFormField(
                controller: _mpesaOrAccountNoController,
                decoration: const InputDecoration(
                  labelText: 'M-Pesa no or Account no',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter M-Pesa or Account number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Upload Passport Size Photo'),
              OutlinedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
              const Text('Upload National ID Image or PDF Document'),
              OutlinedButton(
                onPressed: _pickPdf, // Change to proper picker for PDFs
                child: const Text('Pick PDF or Image'),
              ),
              if (_selectedPdf != null)
                _selectedPdf!.path.endsWith('.pdf')
                    ? PDFView(filePath: _selectedPdf!.path) // Show PDF
                    : Image.file(
                  _selectedPdf!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 20),
              SizedBox(
                height: 35,
                child: OutlinedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ),
              const SizedBox(height: 20),
              const Text('The information Above is necessary for measures against fraud.'),
              const Text('The data you provided also falls under our privacy policy; this data won’t be accessed by any third parties.'),
            ],
          ),
        ),
      ),
    );
  }
}


class Payment{
  String tId;
  Timestamp timestamp;
  double amount;
  String method;
  String status;
  Payment({required this.tId,
    required this.timestamp,
    required this.amount,
    required this.method,required this.status});
}
class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  List<Payment> payments=[];
  @override
  void initState(){
    super.initState();
    payMents();
  }
  void payMents()async{
    QuerySnapshot querySnapshot= await FirebaseFirestore.instance.collection("payments").get();
    if(querySnapshot.docs.isNotEmpty) {
      payments = querySnapshot.docs.map((doc) {
        return Payment(
            tId: doc['transactionId'],
            timestamp: doc['timestamp'],
            amount: doc['amount'],
            method: doc['method'],
            status: doc['status']);
      }).toList();
      payments.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      setState(() {});
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        elevation: 1,
        title: const Text("Transactions", style: TextStyle(color: Colors.black),),
          backgroundColor: Colors.white,
    ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            barGraph(payments),
            SizedBox(height: 20,),
            Text("Latest",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
          payments.isNotEmpty?ListTile(
            title: Text('Transaction ID: ${payments[0].tId}'),
            subtitle: Column(
              children: [
                Text('Amount: \$${payments[0].amount.toStringAsFixed(2)}\nMethod: ${payments[0].method}'),
                dateTime(payments[0].timestamp),
              ],
            ),
            trailing:payments[0].status=="1"? Checkbox(
              value: payments[0].status=="1",
              onChanged: (bool? value) {
              },
            ):Text("Pending..."),
          ):SizedBox.shrink(),
            SizedBox(height:40),
            Text("Earlier",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
            SizedBox(height:20),
           payments.isNotEmpty?ListView.builder(
              itemCount: payments.length-1,
              itemBuilder: (context, index) {
                final payment = payments[index+1];
                return ListTile(
                  title: Text('Transaction ID: ${payment.tId}'),
                  subtitle:  Column(
                    children: [
                      Text('Amount: \$${payment.amount.toStringAsFixed(2)}\nMethod: ${payment.method}'),
                      dateTime(payment.timestamp),
                    ],
                  ),
                  trailing:payment.status=="1"? Checkbox(
                    value: payment.status=="1",
                    onChanged: (bool? value) {
                    },
                  ):Text("Pending..."),
                );
              },
            ):SizedBox.shrink(),
          ],
        ),
      ),
   );
  }
  Widget barGraph(List<Payment> data) {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: BarChart(
            BarChartData(
              barGroups: data.map((payment) {
                return BarChartGroupData(
                  x: payment.timestamp.toDate().millisecondsSinceEpoch,
                  barRods: [
                    BarChartRodData(
                      toY: payment.amount.toDouble(),
                      color: Colors.blueGrey,
                      width: 20,
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40, // Reserve space for titles
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      final formattedDate = DateFormat('dd-MM').format(date);
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          formattedDate,
                          style: TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),
            ),
          ),
        ),
      ],
    );
  }
  Widget dateTime(Timestamp time){
    String date= DateFormat('d MMM').format(time.toDate());
    String hours = DateFormat('HH').format(time.toDate());
    String minutes = DateFormat('mm').format(time.toDate());
    String t = DateFormat('a').format(time.toDate());
    return   Text('payment on $date $hours:$minutes $t', style: const TextStyle(color: Colors.white, fontSize: 11));
    }
  }

