import 'package:fans_arena/clubs/components/clubeventpost.dart';
import 'package:fans_arena/joint/bloc/localhighlights.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Accountchecker5 extends StatefulWidget {
  const Accountchecker5({super.key});
  @override
  _Accountchecker5State createState() => _Accountchecker5State();
}
class _Accountchecker5State extends State<Accountchecker5> {
  late String collectionName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    collectionName = prefs.getString('cname')?? '';
    collectionName = prefs.getString('cname')?? '';
    setState(() {
      isLoading=false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return  const Scaffold(
        body: Center(
          child: SizedBox(
              width: 35,
              height: 35,
              child: CircularProgressIndicator(color: Colors.black)),
        ),
      );
    } else if (collectionName == 'Fan') {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.29,
            child: const LocalHighlights());
      } else if (collectionName == 'Professional') {
        return  SizedBox(
            height: 180,
            width: MediaQuery.of(context).size.width,
            child: const CheckEvents());
      } else if (collectionName == 'Club') {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.29,
            child: const CreateEvent());
      } else {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.29,
            child: const LocalHighlights());

    }
  }
}

class Accountchecker5H extends StatefulWidget {
  const Accountchecker5H({super.key});
  @override
  _Accountchecker5HState createState() => _Accountchecker5HState();
}
class _Accountchecker5HState extends State<Accountchecker5H> {
  late String collectionName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    collectionName = prefs.getString('cname')?? '';
    collectionName = prefs.getString('cname')?? '';
    setState(() {
      isLoading=false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return  const Scaffold(
        body: Center(
          child: SizedBox(
              width: 35,
              height: 35,
              child: CircularProgressIndicator(color: Colors.black)),
        ),
      );
    } else if (collectionName == 'Fan') {
      return const Text("Local HighLights",style: TextStyle(color: Colors.blueGrey,fontSize: 22,fontWeight: FontWeight.bold));
    } else if (collectionName == 'Professional') {
      return  const Text("This Weeks Matches",style: TextStyle(color: Colors.blueGrey,fontSize: 22,fontWeight: FontWeight.bold));
    } else if (collectionName == 'Club') {
      return  InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateHighlight()));
        },
        child: SizedBox(
          height: 35,
          width: 180,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Your Highlights',
                style: TextStyle(color: Colors.blueGrey, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.add_circle_outline_outlined, color: Colors.black,size: 28,),
            ],
          ),
        ),
      );
    } else {
      return const Text("Local HighLights",style: TextStyle(color: Colors.blueGrey,fontSize: 22,fontWeight: FontWeight.bold));

    }
  }
}



























































