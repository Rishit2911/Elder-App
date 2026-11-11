import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Production-ready Camera helper for Android and iOS devices
class WebCameraHelper {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool isInitialized = false;

  Future<bool> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        debugPrint('No physical cameras found on this mobile device.');
        return false;
      }

      // Prioritize front-facing selfie camera for biometric facial verification
      final frontCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Mobile camera initialization error: $e');
      isInitialized = false;
      return false;
    }
  }

  Future<List<int>?> captureSnapshot() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }
    try {
      final xFile = await _controller!.takePicture();
      final bytes = await xFile.readAsBytes();
      return bytes;
    } catch (e) {
      debugPrint('Mobile camera snapshot error: $e');
      return null;
    }
  }

  Widget buildPreview() {
    if (!isInitialized || _controller == null || !_controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller!.value.previewSize?.height ?? 320,
        height: _controller!.value.previewSize?.width ?? 400,
        child: CameraPreview(_controller!),
      ),
    );
  }

  void dispose() {
    try {
      _controller?.dispose();
    } catch (_) {}
    _controller = null;
    isInitialized = false;
  }
}

