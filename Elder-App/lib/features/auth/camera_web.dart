import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class WebCameraHelper {
  html.VideoElement? _videoElement;
  html.MediaStream? _mediaStream;
  final String viewType = 'webcam-view-${DateTime.now().millisecondsSinceEpoch}';
  bool isInitialized = false;

  Future<bool> initializeCamera() async {
    try {
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.transform = 'scaleX(-1)';

      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 640},
          'height': {'ideal': 480},
        },
        'audio': false,
      });

      if (stream != null) {
        _mediaStream = stream;
        _videoElement!.srcObject = stream;
        ui_web.platformViewRegistry.registerViewFactory(
          viewType,
          (int viewId) => _videoElement!,
        );
        isInitialized = true;
        return true;
      }
    } catch (e) {
      debugPrint('Web camera initialization error: $e');
    }
    return false;
  }

  Future<List<int>?> captureSnapshot() async {
    if (_videoElement == null || !isInitialized) return null;
    try {
      final vWidth = _videoElement!.videoWidth > 0 ? _videoElement!.videoWidth : 480;
      final vHeight = _videoElement!.videoHeight > 0 ? _videoElement!.videoHeight : 480;

      // Crop to match the 260x330 (approx 4:5) oval viewfinder with objectFit: cover
      const targetAspect = 260.0 / 330.0;
      double cropWidth;
      double cropHeight;
      double cropX;
      double cropY;

      if ((vWidth / vHeight) > targetAspect) {
        cropHeight = vHeight.toDouble();
        cropWidth = cropHeight * targetAspect;
        cropX = (vWidth - cropWidth) / 2.0;
        cropY = 0.0;
      } else {
        cropWidth = vWidth.toDouble();
        cropHeight = cropWidth / targetAspect;
        cropX = 0.0;
        cropY = (vHeight - cropHeight) / 2.0;
      }

      const outW = 320;
      const outH = 400;
      final canvas = html.CanvasElement(width: outW, height: outH);
      final ctx = canvas.context2D;

      // Mirror horizontally so the capture matches the selfie viewfinder
      ctx.translate(outW, 0);
      ctx.scale(-1, 1);

      ctx.drawImageScaledFromSource(
        _videoElement!,
        cropX, cropY, cropWidth, cropHeight,
        0, 0, outW, outH,
      );

      final dataUrl = canvas.toDataUrl('image/jpeg', 0.90);
      final base64String = dataUrl.split(',')[1];
      return base64Decode(base64String);
    } catch (e) {
      debugPrint('Snapshot capture error: $e');
      return null;
    }
  }

  Widget buildPreview() {
    if (!isInitialized) return const SizedBox.shrink();
    return HtmlElementView(viewType: viewType);
  }

  void dispose() {
    try {
      _mediaStream?.getTracks().forEach((track) => track.stop());
      _videoElement?.pause();
      _videoElement?.srcObject = null;
    } catch (_) {}
  }
}

