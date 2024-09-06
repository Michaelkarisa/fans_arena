import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ItemCount extends StatefulWidget {
  String collection;
  String subCollection;
  String docId;
  ItemCount({super.key,
    required this.collection,
    required this.subCollection,
    required this.docId});

  @override
  State<ItemCount> createState() => _ItemCountState();
}

class _ItemCountState extends State<ItemCount> {
  ItemCountProvider i=ItemCountProvider();
  @override
  void initState() {
    super.initState();
    checkIfUserLikedPost();
  }
  void checkIfUserLikedPost() async {
    await i.getAllitems(widget.collection, widget.docId,widget.subCollection);
  }
  @override
  Widget build(BuildContext context) {
    return  AnimatedBuilder(animation: i,
    builder: (BuildContext context, Widget? child) {
      int totalLikes=i.items.length;
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
    });
  }
}
class ItemCountProvider extends ChangeNotifier{
  List<Map<String,dynamic>>items=[];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> stream;
  Future<void> getAllitems(String collection,String docId,String subCollection)async{
    try {
      stream = _firestore
          .collection(collection)
          .doc(docId)
          .collection(subCollection)
          .snapshots();
      stream.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<QueryDocumentSnapshot> docs = snapshot.docs;
          List<Map<String, dynamic>> alllikes = [];
          for (final doc in docs) {
            final List<Map<String,dynamic>> chats = List<Map<String,dynamic>>.from(doc[subCollection]);
            alllikes.addAll(chats);
          }
          items=alllikes;
          notifyListeners();
        } else {
        }
        notifyListeners();
      });
    } catch (e) {
      notifyListeners();
    }
  }
}