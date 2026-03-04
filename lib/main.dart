import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart'; // import the new file

void main() {
  runApp(const ProviderScope(child: MyApp()));
}