import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Longest edge (px) a stored profile photo is downscaled to.
const int _maxDimension = 320;

/// JPEG quality (0-100) used when re-encoding profile photos.
const int _jpegQuality = 80;

/// Resizes and compresses raw image [bytes] into a small base64 JPEG data URL
/// suitable for storing directly on the patient document in Firestore.
String compressProfilePhoto(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    // Unknown format — store as-is rather than failing the upload.
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }

  final longestEdge = decoded.width > decoded.height ? decoded.width : decoded.height;
  final resized = longestEdge > _maxDimension
      ? img.copyResize(
          decoded,
          width: decoded.width >= decoded.height ? _maxDimension : null,
          height: decoded.height > decoded.width ? _maxDimension : null,
          interpolation: img.Interpolation.average,
        )
      : decoded;

  final jpg = img.encodeJpg(resized, quality: _jpegQuality);
  return 'data:image/jpeg;base64,${base64Encode(jpg)}';
}
