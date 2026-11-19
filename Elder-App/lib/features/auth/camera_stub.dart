import 'package:flutter/material.dart';

class WebCameraHelper {
  final String viewType = 'stub';
  bool isInitialized = false;

  Future<bool> initializeCamera() async => false;

  List<int>? captureSnapshot() => null;

  Widget buildPreview() => const SizedBox.shrink();

  void dispose() {}
}

