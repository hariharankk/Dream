import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ActionButtonRow extends StatelessWidget {
  final VoidCallback onDiscardPressed;
  final VoidCallback onReturnPressed;

  ActionButtonRow({required this.onDiscardPressed, required this.onReturnPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ElevatedButton(
              child: _buttonContent('discard', MdiIcons.closeCircle),
              style: _buttonStyle(),
              onPressed: onDiscardPressed,
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: ElevatedButton(
              style: _buttonStyle(),
              child: _buttonContent('Return', MdiIcons.logoutVariant),
              onPressed: onReturnPressed,
            ),
          )
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.green, // button color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buttonContent(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 26.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 10.0),
          ),
          Icon(icon, size: 10)
        ],
      ),
    );
  }
}
