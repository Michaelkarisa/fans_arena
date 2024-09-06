import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Status extends StatefulWidget {
 Timestamp timestamp;
 String status;
  Status({super.key, required this.timestamp,required this.status});

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
   String state='1';
  String state1='0';
  String state2='';
  String statusName='';

   @override
   void didUpdateWidget(covariant Status oldWidget) {
     DateTime scheduledDate = widget.timestamp.toDate();
     if (widget.status == state && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day == DateTime.now().day) {
       setState(() {
         statusName = 'ongoing';
       });
     } else if (widget.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day < DateTime.now().day) {
       setState(() {
         statusName = 'played';
       });
     } else if (widget.status == state2 && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day > DateTime.now().day) {
       setState(() {
         statusName = 'upcoming';
       });
     } else if (widget.status == state2 && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day < DateTime.now().day) {
       setState(() {
         statusName = 'not played';
       });
     } else if (widget.status == state2 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day < DateTime.now().day) {
       setState(() {
         statusName = 'not played';
       });
     } else if (widget.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day < DateTime.now().day) {
       setState(() {
         statusName = 'played';
       });
     } else if (widget.status == state2 && scheduledDate.year == DateTime.now().year && scheduledDate.month > DateTime.now().month && scheduledDate.day > DateTime.now().day) {
       setState(() {
         statusName = 'upcoming';
       });
     } else if (widget.status == state2 && scheduledDate.year < DateTime.now().year ) {
       setState(() {
         statusName = 'not played';
       });
     } else if (widget.status == state1 && scheduledDate.year < DateTime.now().year ) {
       setState(() {
         statusName = 'played';
       });
     } else if (widget.status == state2 && scheduledDate.year > DateTime.now().year ) {
       setState(() {
         statusName = 'upcoming';
       });
     } else if (widget.status == state2 && scheduledDate.year < DateTime.now().year ) {
       setState(() {
         statusName = 'not played';
       });
     } else if (widget.status == state1 && scheduledDate.year < DateTime.now().year ) {
       setState(() {
         statusName = 'played';
       });
     } else if (widget.status == state2 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day > DateTime.now().day) {
       setState(() {
         statusName = 'not played';
       });
     } else if (widget.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day > DateTime.now().day) {
       setState(() {
         statusName = 'played';
       });
     } else if (widget.status == state2 && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day == DateTime.now().day) {
       setState(() {
         statusName = 'upcoming';
       });
     } else if (widget.status == state2 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day == DateTime.now().day) {
       setState(() {
         statusName = 'not played';
       });
     } else if (widget.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day == DateTime.now().day) {
       setState(() {
         statusName = 'played';
       });
     }
     super.didUpdateWidget(oldWidget);
   }
  @override
  void initState() {
    super.initState();
    DateTime scheduledDate = widget.timestamp.toDate();
    if (widget.status == state && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day == DateTime.now().day) {
      setState(() {
        statusName = 'ongoing';
      });
    } else if (widget.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day < DateTime.now().day) {
      setState(() {
        statusName = 'played';
      });
    } else if (widget.status == state2 && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day > DateTime.now().day) {
      setState(() {
        statusName = 'upcoming';
      });
    } else if (widget.status == state2 && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day < DateTime.now().day) {
      setState(() {
        statusName = 'not played';
      });
    } else if (widget.status == state2 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day < DateTime.now().day) {
      setState(() {
        statusName = 'not played';
      });
    } else if (widget.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day < DateTime.now().day) {
      setState(() {
        statusName = 'played';
      });
    } else if (widget.status == state2 && scheduledDate.year == DateTime.now().year && scheduledDate.month > DateTime.now().month && scheduledDate.day > DateTime.now().day) {
      setState(() {
        statusName = 'upcoming';
      });
    } else if (widget.status == state2 && scheduledDate.year < DateTime.now().year ) {
      setState(() {
        statusName = 'not played';
      });
    } else if (widget.status == state1 && scheduledDate.year < DateTime.now().year ) {
      setState(() {
        statusName = 'played';
      });
    } else if (widget.status == state2 && scheduledDate.year > DateTime.now().year ) {
      setState(() {
        statusName = 'upcoming';
      });
    } else if (widget.status == state2 && scheduledDate.year < DateTime.now().year ) {
      setState(() {
        statusName = 'not played';
      });
    } else if (widget.status == state1 && scheduledDate.year < DateTime.now().year ) {
      setState(() {
        statusName = 'played';
      });
    } else if (widget.status == state2 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day > DateTime.now().day) {
      setState(() {
        statusName = 'not played';
      });
    } else if (widget.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day > DateTime.now().day) {
      setState(() {
        statusName = 'played';
      });
    } else if (widget.status == state2 && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day == DateTime.now().day) {
      setState(() {
        statusName = 'upcoming';
      });
    } else if (widget.status == state2 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day == DateTime.now().day) {
      setState(() {
        statusName = 'not played';
      });
    } else if (widget.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day == DateTime.now().day) {
      setState(() {
        statusName = 'played';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
       if(statusName=='upcoming'){
         return const Text('Upcoming');
       }else if(statusName=='ongoing'){
         return const Text('Ongoing');
       }else if(statusName=='played'){
         return const Text('Played');
       }else if(statusName=='not played'){
         return const Text('Not Played');
       }else{
         return const Text('Unknown');
       }
  }
}

class Drag1 extends StatefulWidget {
 String matchId;
 String leagueId;
 String year;
  Drag1({super.key,required this.matchId,required this.leagueId,required this.year});

  @override
  State<Drag1> createState() => _Drag1State();
}

class _Drag1State extends State<Drag1> {
  TextEditingController location = TextEditingController();
  DateTime? _selectedDate;
  TextEditingController time = TextEditingController();
  DateTime now=DateTime.now();
  void updateLmatch() async {

    try {
      CollectionReference collection = FirebaseFirestore.instance
          .collection('Leagues')
          .doc(widget.leagueId)
          .collection('year')
          .doc(widget.year)
          .collection('leaguematches');

      // Get all documents from the subcollection
      QuerySnapshot querySnapshot = await collection.get();

      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        List<dynamic> clubsteam = documentSnapshot['matches'];

        // Find the index of the array element with matching 'teamId'
        int indexToUpdate = -1;
        for (int i = 0; i < clubsteam.length; i++) {
          if (clubsteam[i]['matchId'] == widget.matchId) {
            indexToUpdate = i;
            break;
          }
        }

        if (indexToUpdate != -1) {
          // Update the 'role' field for the array element
          if(_selectedDate.toString().isNotEmpty){
            clubsteam[indexToUpdate]['scheduledDate'] = _selectedDate;
          }
          if(time.text.isNotEmpty){
            clubsteam[indexToUpdate]['time'] = time;
          }
          if(location.text.isNotEmpty){
            clubsteam[indexToUpdate]['location'] = location;
          }
          // Update the Firestore document with the modified 'clubsteam' array
          await documentSnapshot.reference.update({'matches': clubsteam});
          print('Role updated successfully');
          break; // Exit the loop once the update is done
        }
      }
    } catch (e) {
      print('Error updating role: $e');
    }
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.utc(2050),
    );

    if (picked != null && picked != _selectedDate) {
      // Set the time component to midnight (00:00:00)
      final pickedDateWithoutTime = DateTime(picked.year, picked.month, picked.day);

      setState(() {
        _selectedDate = pickedDateWithoutTime;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return  Align(
      alignment: const Alignment(0.0,0.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: Colors.white,
          height: 250,
          width: MediaQuery.of(context).size.width*0.85,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Edit Match',style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.6,
                  height: 38,
                  child: TextFormField(
                      controller: location,
                      textAlignVertical: TextAlignVertical.bottom,
                      decoration: InputDecoration(
                          labelText: 'Location',
                          hintText: 'Location',
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors
                                    .grey),
                            borderRadius: BorderRadius
                                .circular(8),
                          ),
                          suffixIcon: IconButton(onPressed: (){},icon: const Icon(Icons.search,color: Colors.black,),)
                      )),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.6,
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
                        hintText: 'Date',
                        labelText: 'Date',
                      )),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.6,
                  height: 38,
                  child: TextFormField(
                    onTap: () {
                      showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      ).then((TimeOfDay? value) {
                        if (value != null) {
                          setState(() {
                            time.text = value.format(context);
                          });
                        }
                      });
                    },
                    readOnly: true,
                    controller: time,
                    decoration: InputDecoration(
                      hintText: 'Time',
                      labelText: 'Time',
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors
                                .grey),
                        borderRadius: BorderRadius
                            .circular(8),
                      ),
                    ),
                  ),
                ),

                TextButton(onPressed: updateLmatch, child: const Text('Update'))
              ],
            ),
          ),
        ),
      ),

    );
  }
}


class PlayedCount extends StatefulWidget {
  String leagueId;
  String year;
  PlayedCount({super.key,required this.leagueId,required this.year});

  @override
  State<PlayedCount> createState() => _PlayedCountState();
}

class _PlayedCountState extends State<PlayedCount> {

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
        stream:FirebaseFirestore.instance
            .collection('Leagues')
            .doc(widget.leagueId)
            .collection('year')
            .doc(widget.year)
            .collection('leaguematches')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('0')); // Handle case where there are no likes
          } else {
            final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!.docs;
            List<Map<String, dynamic>> allLikes = [];
            int played=0;
            // Extract and combine all like objects into a single list
            for (final document in likeDocuments) {
              final List<dynamic> likesArray = document['matches'];
              for(final item in likesArray){
                final status=item['status'];
                Timestamp date=item['scheduledDate'];
                DateTime scheduledDate = date.toDate();
                DateTime now=DateTime.now();
                if (status == '0' && scheduledDate.year == now.year && scheduledDate.month < now.month && scheduledDate.day < now.day||status == '0' &&scheduledDate.year == now.year && scheduledDate.month == now.month && scheduledDate.day < now.day||status == '0' &&scheduledDate.year == now.year && scheduledDate.month < now.month && scheduledDate.day > now.day||status == '0' &&scheduledDate.year == now.year && scheduledDate.month < now.month && scheduledDate.day == now.day||status == '0' &&scheduledDate.year < now.year) {
                  allLikes.add(item);
                  played=allLikes.length;
                }
              }
            }
            return Center(child: Text('$played'));}});
  }
}




