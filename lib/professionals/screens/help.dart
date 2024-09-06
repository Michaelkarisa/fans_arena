import 'package:flutter/material.dart';
class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help',style:TextStyle(color: Colors.black) ),
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,),
          onPressed: () {
            Navigator.of(context).pop();
          },//to next page},
        ),
      ),
    );
  }
}
