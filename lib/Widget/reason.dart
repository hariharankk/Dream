import 'package:flutter/material.dart';

class ReasonInputWidget extends StatefulWidget {
  final Function(String) onReasonSubmitted;

  const ReasonInputWidget({required this.onReasonSubmitted});

  @override
  _ReasonInputWidgetState createState() => _ReasonInputWidgetState();
}

class _ReasonInputWidgetState extends State<ReasonInputWidget> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitReason() {
    final reason = _reasonController.text.trim();
    if (reason.isNotEmpty) {
      widget.onReasonSubmitted(reason);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why are you reaching out?',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              labelText: 'Reason',
              hintText: 'Enter your reason here',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit_outlined),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2.0),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: _submitReason,
            style: ElevatedButton.styleFrom(
              primary: Colors.blue, // background color
              onPrimary: Colors.white, // text color
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            child: Text(
              'Submit Reason',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
