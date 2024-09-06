import 'package:flutter/material.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
 bool isEnabled=false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Help', style: TextStyle(color: Colors.black)),
          elevation: 1,
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: IconButton(
            padding: EdgeInsets.zero,
              onPressed: (){
            setState(() {
              isEnabled=!isEnabled;
            });
          },icon:Icon(
            isEnabled ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color:isEnabled? Colors.purple:Colors.grey,
          )),
        ),
      ),
    );
  }
}
