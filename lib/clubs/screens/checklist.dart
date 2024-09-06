import 'package:fans_arena/clubs/screens/clubteamtable.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
class CheckList extends StatefulWidget {
  List<Map<String,dynamic>>dRow;
  List<Map<String,dynamic>> tableColumns;
  String navf;
   CheckList({super.key,
     required this.tableColumns,
     required this.dRow,
     required this.navf});
  @override
  State<CheckList> createState() => _CheckListState();
}
class _CheckListState extends State<CheckList> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.tableColumns[1]['fn']} List'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: widget.dRow.map((d) {
              Timestamp createdAt =  Timestamp.now();
              if(widget.navf=="Club"){
                createdAt = d['addedAt']??Timestamp.now();
              }else{
                createdAt = d['createdAt']??Timestamp.now();
              }
              DateTime createdDateTime = createdAt.toDate();
              String hours = DateFormat('HH').format(createdDateTime);
              String minutes = DateFormat('mm').format(createdDateTime);
              String t = DateFormat('a').format(createdDateTime);
              String date = DateFormat('d MMM').format(createdDateTime);
              return SizedBox(
                width:MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomNameAvatar(userId:d[widget.tableColumns[1]['fn']],radius: 18, style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                    ), maxsize: 70,cloadingname: '${widget.tableColumns[1]['fn']}...',),
                    Text('Added On $date At $hours:$minutes $t',),
                    Status1(status: d['status'],)
                  ]),
                ),
              );}).toList(),
          ),
        ),
      ),
    );
  }
}
