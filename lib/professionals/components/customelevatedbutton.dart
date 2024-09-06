import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String buttonText;
  final Function onPressed;

  const CustomElevatedButton({super.key, required this.buttonText, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed as void Function()?,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.white),
            ),
          ),
        ),
        child: Text(buttonText,style: const TextStyle(color: Colors.black),),
      ),
    );
  }
}
