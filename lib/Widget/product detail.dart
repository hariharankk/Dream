import 'package:flutter/material.dart';

Widget ProductDetailCard(String title, String data) {
  return Column(
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
      SizedBox(height: 20),
      Text(
        data,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    ],
  );
}