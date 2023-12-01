import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:inventory/Getx/timer.dart';

class CountdownTimerWidget extends StatelessWidget {
  final CountdownController _controller = Get.find<CountdownController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.timer, color: Colors.blue),
          SizedBox(width: 10),
          Obx(() {
            final hours = _controller.twoDigits(_controller.remainingTime.value.inHours);
            final minutes = _controller.twoDigits(_controller.remainingTime.value.inMinutes.remainder(60));
            final seconds = _controller.twoDigits(_controller.remainingTime.value.inSeconds.remainder(60));
            return Text(
              '$hours:$minutes:$seconds',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            );
          }),
        ],
      ),
    );
  }
}
