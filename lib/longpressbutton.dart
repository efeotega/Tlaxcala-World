import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LongPressButton extends StatefulWidget {
  const LongPressButton({super.key});

  @override
  _LongPressButtonState createState() => _LongPressButtonState();
}

class _LongPressButtonState extends State<LongPressButton> {
  Timer? _pressTimer;
  bool _isLongPressed = false;

  @override
  void dispose() {
    _pressTimer?.cancel();
    super.dispose();
  }

  void _onLongPressStart(BuildContext context) {
    // Start a timer for 15 seconds
    _pressTimer = Timer(const Duration(seconds: 15), () {
      setState(() {
        _isLongPressed = true;
      });
      Navigator.pushNamed(context, '/login');
    });
  }

  void _onLongPressEnd() {
    // Cancel the timer if the press is released early
    _pressTimer?.cancel();
    setState(() {
      _isLongPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/menu');
      },
      onLongPressStart: (_) => _onLongPressStart(context),
      onLongPressEnd: (_) => _onLongPressEnd(),
      child: Padding(
        padding: const EdgeInsets.only(left:20.0,right:20.0),
        child: Container(
          width:MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color:    const Color(0xFFF95B3D),
          ),
          child: Center(
            child: Padding(
               padding: const EdgeInsets.only(top:16.0,bottom:16.0),
               child:Text(
              context.tr('Access'),
              style: const TextStyle(color:    Colors.white),
            ),
            ),
          )
        ),
      ),
    );
  }
}
