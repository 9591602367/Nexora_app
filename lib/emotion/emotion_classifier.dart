import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
 
/// One classification result: the winning emotion and how confident the model is.
class EmotionResult {
  final String label;
  final double confidence; // 0.0 - 1.0
 
  const EmotionResult(this.label, this.confidence);
}
 
/// Loads the trained emotion model and classifies a cropped face image.
///
/// The model was trained on 48x48 grayscale faces with pixel values scaled
/// to 0-1, so the preprocessing here must match exactly.
class EmotionClassifier {
  static const int inputSize = 48;
  static const String modelAsset = 'assets/models/emotion_model.tflite';
  static const String labelsAsset = 'assets/models/labels.txt';
 
  Interpreter? _interpreter;
  List<String> _labels = [];
 
  bool get isReady => _interpreter != null && _labels.isNotEmpty;
 
  Future<void> load() async {
    _interpreter = await Interpreter.fromAsset(modelAsset);
    final raw = await rootBundle.loadString(labelsAsset);
    _labels = raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }
 
  EmotionResult classify(img.Image face) {
    final interpreter = _interpreter;
    if (interpreter == null || _labels.isEmpty) {
      throw StateError('EmotionClassifier.load() must finish before classify().');
    }
 
    // Resize to 48x48 and convert to grayscale.
    final gray = img.grayscale(
      img.copyResize(face, width: inputSize, height: inputSize),
    );
 
    // Build input tensor of shape [1, 48, 48, 1], values 0-1.
    final input = [
      List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) => [gray.getPixel(x, y).r / 255.0],
        ),
      ),
    ];
 
    final output = [List<double>.filled(_labels.length, 0.0)];
    interpreter.run(input, output);
 
    final scores = output[0];
    var best = 0;
    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > scores[best]) best = i;
    }
    return EmotionResult(_labels[best], scores[best]);
  }
 
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
 