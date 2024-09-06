import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class ThumbnailRequest {
  final String video;
  final String thumbnailPath;
  final ImageFormat imageFormat;
  final int maxHeight;
  final int maxWidth;
  final int timeMs;
  final int quality;

  const ThumbnailRequest(
      {required this.video,
        required this.thumbnailPath,
        required this.imageFormat,
        required this.maxHeight,
        required this.maxWidth,
        required this.timeMs,
        required this.quality});
}

class ThumbnailResult {
  final File image;
  final int dataSize;
  final int height;
  final int width;
  const ThumbnailResult({required this.image,
    required this.dataSize, required this.height,
    required this.width});
}

Future<ThumbnailResult> genThumbnail(ThumbnailRequest r) async {
  Uint8List? bytes;
  final Completer<ThumbnailResult> completer = Completer();

  if (r.thumbnailPath.isNotEmpty) {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: r.video,
      headers: {
        "USERHEADER1": "user defined header1",
        "USERHEADER2": "user defined header2",
      },
      thumbnailPath: r.thumbnailPath!,
      imageFormat: r.imageFormat,
      maxHeight: r.maxHeight,
      maxWidth: r.maxWidth,
      timeMs: r.timeMs,
      quality: r.quality,
    );

    print("Thumbnail file path: $thumbnailPath");

    final file = File(thumbnailPath!);
    bytes = await file.readAsBytes();
  } else {
    bytes = await VideoThumbnail.thumbnailData(
      video: r.video,
      headers: {
        "USERHEADER1": "user defined header1",
        "USERHEADER2": "user defined header2",
      },
      imageFormat: r.imageFormat,
      maxHeight: r.maxHeight,
      maxWidth: r.maxWidth,
      timeMs: r.timeMs,
      quality: r.quality,
    );
  }

  if (bytes == null) {
    completer.completeError("Failed to generate thumbnail.");
  } else {
    int? _imageDataSize = bytes.length;
    print("Image size: $_imageDataSize bytes");

    // Save bytes to a temporary file
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/thumbnail.${r.imageFormat.toString().split('.').last.toLowerCase()}');
    await tempFile.writeAsBytes(bytes);
    completer.complete(ThumbnailResult(
      image: tempFile,
      dataSize: _imageDataSize!,
      height: r.maxHeight ?? 0, // Replace with actual height if available
      width: r.maxWidth ?? 0,   // Replace with actual width if available
    ));
  }

  return completer.future;
}
