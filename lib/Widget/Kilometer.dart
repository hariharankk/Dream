import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final Function(String) onChanged;
  final String hintText;
  final bool isInvalid;

  CustomTextField({
    required this.onChanged,
    required this.hintText,
    this.isInvalid = false, // Default value is false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(5.0),
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: hintText,
          border: OutlineInputBorder(),
          hintText: hintText,
          errorText: isInvalid ? "Invalid ID" : null,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
