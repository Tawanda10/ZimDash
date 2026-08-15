import 'package:flutter/material.dart';

/// A small pill-shaped popup at the bottom of the screen, mirroring the
/// original web app's `.toast` element.
void showZimToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF16130F),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        margin: const EdgeInsets.only(bottom: 24, left: 60, right: 60),
        elevation: 8,
      ),
    );
}
