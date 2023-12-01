import 'package:flutter/material.dart';

class CustomPhotoButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  CustomPhotoButton({required this.onPressed, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15.0),
      // Adding a margin around the TextButton.
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white, // Text color
          backgroundColor: Colors.blue, // Button color
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          // Adding padding inside the TextButton.
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt),
              SizedBox(width: 8.0),
              Text(
                buttonText,
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
