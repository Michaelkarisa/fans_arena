import 'package:fans_arena/fans/bloc/accountchecker1.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:flutter/material.dart';

class Accountchecker14 extends StatefulWidget {
Person user;
  Accountchecker14({super.key,required this.user});

  @override
  _Accountchecker14State createState() => _Accountchecker14State();
}
class _Accountchecker14State extends State<Accountchecker14> {
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading=false;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox.shrink();
    } else if (widget.user.collectionName == 'Fan'||widget.user.collectionName == 'Professional') {
      return Accountchecker1(user: widget.user,);
    } else {
      // Execute process if email is not found in any collection
      return const SizedBox.shrink();
    }
  }
}

