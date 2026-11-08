import 'dart:io';
import 'dart:ui' show Rect;
 
import 'package:image/image.dart' as img;
 
/// Reads an image file and applies its EXIF rotation so it is upright.
/// Returns null if the file can't be decoded.
Future<img.Image?> decodeUpright(String path) async {
  final bytes = await File(path).readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  return img.bakeOrientation(decoded);
}
 
/// Crops [box] (a face bounding box) out of [src], with a little padding,
/// clamped so it never goes outside the image.
img.Image cropFace(img.Image src, Rect box, {double padding = 0.15}) {
  final padX = box.width * padding;
  final padY = box.height * padding;
 
  final left = (box.left - padX).clamp(0, src.width - 1).toInt();
  final top = (box.top - padY).clamp(0, src.height - 1).toInt();
  final right = (box.right + padX).clamp(left + 1, src.width).toInt();
  final bottom = (box.bottom + padY).clamp(top + 1, src.height).toInt();
 
  return img.copyCrop(
    src,
    x: left,
    y: top,
    width: right - left,
    height: bottom - top,
  );
}
 
