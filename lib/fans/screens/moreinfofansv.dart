import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Moreinfofansv extends StatefulWidget {
  String userId;
  Moreinfofansv({super.key,required this.userId});
  @override
  State<Moreinfofansv> createState() => _MoreinfofansvState();
}
class _MoreinfofansvState extends State<Moreinfofansv> {
  Timestamp timestamp = Timestamp.now();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    userData();
  }
  late Stream<DocumentSnapshot> _stream1;
  void userData() {
    _stream1 = firestore.collection('Fans').doc(widget.userId).snapshots();
    _stream1.listen((snapshot) {
      final newValue = (snapshot.data() as Map<String, dynamic>)['birthday'];
      setState(() {
        timestamp=newValue;
      });
    });}
  @override
  Widget build(BuildContext context) {
    String date = DateFormat('d MMM y').format(timestamp.toDate());
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: const Text('More info',style: TextStyle(color: Colors.black),),
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.calendar_month,size: 55,color: Colors.black,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date Of Birth",style:TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                      SizedBox(height: 5,),
                      Text(date)
                    ],
                  )
                ],
              ),
              SizedBox(height: 10,),
              Text('Interests',style: TextStyle(fontWeight: FontWeight.bold
              )),
              Text('Best moments',style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}