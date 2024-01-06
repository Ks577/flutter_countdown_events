import 'package:flutter/material.dart';

Widget countDownStyle({required Widget child}) {
  return Container(
    height: 70,
    width: 70,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.purple.withOpacity(1),
          blurRadius: 1,
          offset: const Offset(1, 1),
        ),
      ],
    ),
    child: child,
  );
}
