import 'package:flutter/material.dart';
class Textformfiedw extends StatefulWidget {
  const Textformfiedw({super.key});

  @override
  State<Textformfiedw> createState() => _TextformfiedwState();
}
TextEditingController _controller = TextEditingController();
bool _showCloseIcon = false;

class _TextformfiedwState extends State<Textformfiedw> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textAlign: TextAlign.justify,
      textAlignVertical: TextAlignVertical.bottom,
      cursorColor: Colors.black,
      controller: _controller,
      onChanged: (value) {
        setState(() {
          _showCloseIcon = value.isNotEmpty;
        });
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(width: 1, color: Colors.black),
        ),
        focusedBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(width: 1, color: Colors.black),
        ),
        filled: true,
        hintStyle: const TextStyle(color: Colors.black,
          fontSize: 14, fontWeight: FontWeight.normal,),
        fillColor: Colors.white70,
        suffixIcon: _showCloseIcon ? IconButton(
          icon: const Icon(Icons.close,color: Colors.black,),
          onPressed: () {
            setState(() {
              _controller.clear();
              _showCloseIcon = false;
            });
          },
        ) : null,
        hintText: 'Search',
      ),
    );
  }
}
