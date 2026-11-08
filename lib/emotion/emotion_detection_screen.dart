import 'dart:async';
import 'dart:io';
 
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
 
import 'emotion_classifier.dart';
import 'image_utils.dart';
 
/// Camera screen: detection only runs while the user has pressed "Start".
///
/// Approach: while running, a photo is taken every ~800 ms, the face is found
/// with ML Kit, cropped, and classified on-device. Photos are deleted right
/// after use, and nothing is uploaded.
class EmotionDetectionScreen extends StatefulWidget {
  const EmotionDetectionScreen({super.key});
 
  @override
  State<EmotionDetectionScreen> createState() => _EmotionDetectionScreenState();
}
 
class _EmotionDetectionScreenState extends State<EmotionDetectionScreen>
    with WidgetsBindingObserver {
  static const _interval = Duration(milliseconds: 800);
  static const _smoothingWindow = 5;
 
  final _classifier = EmotionClassifier();
  final _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
  );
 
  CameraController? _controller;
  Timer? _timer;
  bool _modelReady = false;
  bool _running = false;
  bool _busy = false; // true while one frame is being processed
  String _status = 'Loading model...';
  final List<String> _recent = [];
 
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadModel();
  }
 
  Future<void> _loadModel() async {
    try {
      await _classifier.load();
      if (!mounted) return;
      setState(() {
        _modelReady = true;
        _status = 'Tap Start to detect emotion';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Could not load model: $e');
    }
  }
 
  Future<void> _start() async {
    if (!_modelReady || _running) return;
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _status = 'No camera found');
        return;
      }
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      _controller = controller;
      _recent.clear();
      setState(() {
        _running = true;
        _status = 'Looking for a face...';
      });
      _timer = Timer.periodic(_interval, (_) => _analyzeFrame());
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() => _status = e.code == 'CameraAccessDenied'
          ? 'Camera permission is needed'
          : 'Camera error: ${e.description ?? e.code}');
    }
  }
 
  Future<void> _stop() async {
    _timer?.cancel();
    _timer = null;
    final controller = _controller;
    _controller = null;
    if (mounted) {
      setState(() {
        _running = false;
        _status = 'Tap Start to detect emotion';
      });
    }
    await controller?.dispose();
  }
 
  Future<void> _analyzeFrame() async {
    final controller = _controller;
    if (_busy ||
        controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }
    _busy = true;
    String? path;
    try {
      final file = await controller.takePicture();
      path = file.path;
 
      final faces =
          await _faceDetector.processImage(InputImage.fromFilePath(path));
      if (faces.isEmpty) {
        _recent.clear();
        _setStatus('No face detected');
        return;
      }
 
      // Use the largest face in the frame.
      final face = faces.reduce((a, b) =>
          a.boundingBox.width >= b.boundingBox.width ? a : b);
 
      final upright = await decodeUpright(path);
      if (upright == null) return;
 
      final result = _classifier.classify(cropFace(upright, face.boundingBox));
 
      // Smooth over the last few results to avoid flickering.
      _recent.add(result.label);
      if (_recent.length > _smoothingWindow) _recent.removeAt(0);
      final counts = <String, int>{};
      for (final l in _recent) {
        counts[l] = (counts[l] ?? 0) + 1;
      }
      final smoothed =
          counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
 
      final pct = (result.confidence * 100).round();
      _setStatus('${_capitalize(smoothed)}  ($pct% on last frame)');
    } catch (e) {
      _setStatus('Detection error: $e');
    } finally {
      // Delete the temporary photo straight away.
      if (path != null) {
        try {
          await File(path).delete();
        } catch (_) {}
      }
      _busy = false;
    }
  }
 
  void _setStatus(String text) {
    if (mounted && _running) setState(() => _status = text);
  }
 
  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
 
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop the camera if the app goes to the background.
    if (state != AppLifecycleState.resumed && _running) {
      _stop();
    }
  }
 
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller?.dispose();
    _faceDetector.close();
    _classifier.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Emotion detection')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _running &&
                      controller != null &&
                      controller.value.isInitialized
                  ? CameraPreview(controller)
                  : const Icon(Icons.face, size: 96, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _status,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'The camera is only used while detection is running. '
              'Images are processed on this device and deleted immediately.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: !_modelReady
                    ? null
                    : (_running ? _stop : _start),
                child: Text(_running ? 'Stop detection' : 'Start detection'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 