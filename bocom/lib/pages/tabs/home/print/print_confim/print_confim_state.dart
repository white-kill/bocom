import 'package:flutter/material.dart';

class PrintConfimState {
  final TextEditingController emailController = TextEditingController();

  void dispose() {
    emailController.dispose();
  }
}
