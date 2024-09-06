import 'package:fans_arena/joint/components/colors.dart';
import 'package:flutter/material.dart';
class Addpost extends StatefulWidget {
  const Addpost({super.key});

  @override
  State<Addpost> createState() => _AddpostState();
}

class _AddpostState extends State<Addpost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,),
          onPressed: () {
            Navigator.of(context).pop();
          },//to next page},
        ),
        title: const Text('Add post'),
        backgroundColor:Appbare,
      ),
    );
  }
}
