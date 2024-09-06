import 'dart:async';
import 'dart:io';
import 'package:ffmpeg_kit_flutter/log_callback.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'color_extensions.dart';
import 'package:fans_arena/reusablewidgets/v.dart';
import 'package:fans_arena/reusablewidgets/video_trimmer.dart';

class Trimmer {
  final StreamController<TrimmerEvent> _controller =
  StreamController<TrimmerEvent>.broadcast();

  VideoPlayerController? _videoPlayerController;

  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  File? currentVideoFile;

  Stream<TrimmerEvent> get eventStream => _controller.stream;

  Future<void> loadVideo({required File videoFile}) async {
    print("loading controller....");
    try {
      currentVideoFile = videoFile;
      if (videoFile.existsSync()) {
        _videoPlayerController = VideoPlayerController.file(currentVideoFile!);
        await _videoPlayerController!.initialize().then((_) {
          _controller.add(TrimmerEvent.initialized);
        });
      }
      print("controller loaded successfully");
    } catch (e) {
      print("error loading controller: $e");
    }
  }

  bool get isVideoPlayerInitialized =>
      _videoPlayerController != null &&
          _videoPlayerController!.value.isInitialized;

  Future<String> _createFolderInAppDocDir(String folderName,
      StorageDir? storageDir,) async {
    Directory? directory;

    if (storageDir == null) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      switch (storageDir.toString()) {
        case 'temporaryDirectory':
          directory = await getTemporaryDirectory();
          break;

        case 'applicationDocumentsDirectory':
          directory = await getApplicationDocumentsDirectory();
          break;

        case 'externalStorageDirectory':
          directory = await getExternalStorageDirectory();
          break;
      }
    }

    final Directory directoryFolder =
    Directory('${directory!.path}/$folderName/');

    if (await directoryFolder.exists()) {
      return directoryFolder.path;
    } else {
      final Directory directoryNewFolder =
      await directoryFolder.create(recursive: true);
      return directoryNewFolder.path;
    }
  }

  String modifiedFilePath = '';

  Future<void> saveTrimmedVideo({
    required double startValue,
    required double endValue,
    required Function(String? outputPath) onSave,
    bool applyVideoEncoding = false,
    FileFormat? outputFormat,
    String? ffmpegCommand,
    String? customVideoFormat,
    int? fpsGIF,
    int? scaleGIF,
    String? videoFolderName,
    String? videoFileName,
    StorageDir? storageDir,
  }) async {
    final String videoPath = modifiedFilePath;
    final String videoName = basename(videoPath).split('.')[0];

    String command;

    String dateTime = DateFormat.yMMMd()
        .addPattern('-')
        .add_Hms()
        .format(DateTime.now())
        .toString();

    String outputPath;
    String? outputFormatString;
    String formattedDateTime = dateTime.replaceAll(' ', '');

    videoFolderName ??= "Trimmer";

    videoFileName ??= "${videoName}_trimmed:$formattedDateTime";

    videoFileName = videoFileName.replaceAll(' ', '_');

    String path = await _createFolderInAppDocDir(
      videoFolderName,
      storageDir,
    ).whenComplete(() => debugPrint("Retrieved Trimmer folder"));

    Duration startPoint = Duration(milliseconds: startValue.toInt());
    Duration endPoint = Duration(milliseconds: endValue.toInt());

    if (outputFormat == null) {
      outputFormat = FileFormat.mp4;
      outputFormatString = outputFormat.toString();
    } else {
      outputFormatString = outputFormat.toString();
    }

    String trimLengthCommand =
        ' -ss $startPoint -i "$videoPath" -t ${endPoint -
        startPoint} -avoid_negative_ts make_zero ';

    if (ffmpegCommand == null) {
      command = '$trimLengthCommand -c:a copy ';

      if (!applyVideoEncoding) {
        command += '-c:v copy ';
      }

      if (outputFormat == FileFormat.gif) {
        fpsGIF ??= 10;
        scaleGIF ??= 480;
        command =
        '$trimLengthCommand -vf "fps=$fpsGIF,scale=$scaleGIF:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 ';
      }
    } else {
      command = '$trimLengthCommand $ffmpegCommand ';
      outputFormatString = customVideoFormat;
    }

    outputPath = '$path$videoFileName$outputFormatString';

    command += '"$outputPath"';

    FFmpegKit.executeAsync(command, (session) async {
      FFmpegKitConfig.sessionStateToString(await session.getState());
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        onSave(outputPath);
        await loadVideo(videoFile: File(outputPath));
        modifiedFilePath = outputPath;
      } else {
        onSave(null);
      }
    });
  }

  Future<void> removeModifications() async {
    await loadVideo(videoFile: currentVideoFile!);
  }

  Future<void> addFadeEffect({
    required int fadeInStart,
    required int fadeInDuration,
    required int fadeOutStart,
    required int fadeOutDuration,
    required Function(String? outputPath) onSave,
    String? videoFolderName,
    String? videoFileName,
    StorageDir? storageDir,}) async {
    try {
      String dateTime = DateFormat.yMMMd().addPattern('-').add_Hms().format(
          DateTime.now()).toString();
      String formattedDateTime = dateTime.replaceAll(' ', '');
      videoFolderName ??= "Trimmer";
      videoFileName ??= "fade_$formattedDateTime";

      String path = await _createFolderInAppDocDir(videoFolderName, storageDir);
      String outputPath = '$path$videoFileName.mp4';
      String command = "-i $modifiedFilePath -vf \"fade=in:$fadeInStart:$fadeInDuration,fade=out:$fadeOutStart:$fadeOutDuration\" $outputPath";
      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSave(outputPath);
          await loadVideo(videoFile: File(outputPath));
          modifiedFilePath = outputPath;
        } else {
          onSave(null);
        }
      });
    } catch (e) {
      onSave(null);
    }
  }

  Future<void> cropVideo({
    required int cropHeight,
    required Function(String? outputPath) onSave,
    String? videoFolderName,
    String? videoFileName,
    StorageDir? storageDir,
  }) async {
    try {
      String dateTime = DateFormat.yMMMd().addPattern('-').add_Hms().format(
          DateTime.now()).toString();
      String formattedDateTime = dateTime.replaceAll(' ', '');
      videoFolderName ??= "Trimmer";
      videoFileName ??= "cropped_$formattedDateTime";

      String path = await _createFolderInAppDocDir(videoFolderName, storageDir);
      String outputPath = '$path$videoFileName.mp4';

      String command = "-i $modifiedFilePath -vf crop=in_w:in_h-$cropHeight:0:${cropHeight ~/
          2} \"$outputPath\"";

      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSave(outputPath);
          await loadVideo(videoFile: File(outputPath));
          modifiedFilePath = outputPath;
        } else {
          onSave(null);
        }
      });
    } catch (e) {
      onSave(null);
    }
  }

  Future<void> adjustBrightness({
    required double brightness,
    required Function(String? outputPath) onSave,
    String? videoFolderName,
    String? videoFileName,
    StorageDir? storageDir,
  }) async {
    try {
      String dateTime = DateFormat.yMMMd().addPattern('-').add_Hms().format(
          DateTime.now()).toString();
      String formattedDateTime = dateTime.replaceAll(' ', '');
      videoFolderName ??= "Trimmer";
      videoFileName ??= "brightness_$formattedDateTime";

      String path = await _createFolderInAppDocDir(videoFolderName, storageDir);
      String outputPath = '$path$videoFileName.mp4';

      String command = "-i $modifiedFilePath -vf eq=brightness=$brightness \"$outputPath\"";

      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSave(outputPath);
          await loadVideo(videoFile: File(outputPath));
          modifiedFilePath = outputPath;
        } else {
          onSave(null);
        }
      });
    } catch (e) {
      print("error adjusting brightness: $e");
      onSave(null);
    }
  }

  Future<void> adjustSaturation({
    required double saturation,
    required Function(String? outputPath) onSave,
    String? videoFolderName,
    String? videoFileName,
    StorageDir? storageDir,
  }) async {
    try {
      String dateTime = DateFormat.yMMMd().addPattern('-').add_Hms().format(
          DateTime.now()).toString();
      String formattedDateTime = dateTime.replaceAll(' ', '');
      videoFolderName ??= "Trimmer";
      videoFileName ??= "saturation_$formattedDateTime";

      String path = await _createFolderInAppDocDir(videoFolderName, storageDir);
      String outputPath = '$path$videoFileName.mp4';

      String command = "-i $modifiedFilePath -vf eq=saturation=$saturation \"$outputPath\"";

      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSave(outputPath);
          await loadVideo(videoFile: File(outputPath));
          modifiedFilePath = outputPath;
        } else {
          onSave(null);
        }
      });
    } catch (e) {
      onSave(null);
    }
  }

  Future<void> trimAudio({
    required String outputPath,
    required Duration startTime,
    required Duration endTime,
    required Function(String? outputPath) onSave,
    String? videoFolderName,
    String? videoFileName,
    StorageDir? storageDir,
  }) async {
    try {
      String dateTime = DateFormat.yMMMd().addPattern('-').add_Hms().format(
          DateTime.now()).toString();
      String formattedDateTime = dateTime.replaceAll(' ', '');
      videoFolderName ??= "Trimmer";
      videoFileName ??= "audioTrimmer_$formattedDateTime";

      String path = await _createFolderInAppDocDir(videoFolderName, storageDir);
      String outputPath = '$path$videoFileName.mp3';
      int startMs = startTime.inMilliseconds;
      int endMs = endTime.inMilliseconds;

      // Calculate the duration of the segment to trim
      int durationMs = endMs - startMs;

      // Construct the FFmpeg command for trimming the audio
      String command = "-i $modifiedFilePath -ss ${startTime
          .inSeconds} -t ${durationMs / 1000} -c copy \"$outputPath\"";

      // Execute the FFmpeg command asynchronously
      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSave(outputPath);
          await loadVideo(videoFile: File(outputPath));
          modifiedFilePath = outputPath;
        } else {
          // Invoke the callback with null if there was an error
          onSave(null);
        }
      });
    } catch (e) {
      // Invoke the callback with null if an exception occurred
      onSave(null);
    }
  }

  Future<void> rotateVideo({
    required double angle, // Angle in degrees
    required Function(String? outputPath) onSave,
    String? videoFolderName,
    String? videoFileName,
    StorageDir? storageDir,
  }) async {
    try {
      // Format the current date and time for unique file naming
      String dateTime = DateFormat.yMMMd().addPattern('-').add_Hms().format(
          DateTime.now()).toString();
      String formattedDateTime = dateTime.replaceAll(' ', '');
      videoFolderName ??= "Trimmer";
      videoFileName ??= "rotate_$formattedDateTime";

      // Create the folder and construct the output path
      String path = await _createFolderInAppDocDir(videoFolderName, storageDir);
      String outputPath = '$path$videoFileName.mp4';

      // Construct the FFmpeg command for rotating the video by the specified angle
      String command = "-i $modifiedFilePath -vf \"rotate=${angle}*PI/180\" \"$outputPath\"";

      // Execute the FFmpeg command asynchronously
      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSave(outputPath);
          await loadVideo(videoFile: File(outputPath));
          modifiedFilePath = outputPath;
        } else {
          // Invoke the callback with null if there was an error
          onSave(null);
        }
      });
    } catch (e) {
      // Invoke the callback with null if an exception occurred
      onSave(null);
    }
  }


  Future<void> flipVideo({
    required bool horizontal,
    required Function(String? outputPath) onSave,
    String? videoFolderName,
    String? videoFileName,
    StorageDir? storageDir,
  }) async {
    try {
      String flipDirection = horizontal ? "hflip" : "vflip";
      String dateTime = DateFormat.yMMMd().addPattern('-').add_Hms().format(
          DateTime.now()).toString();
      String formattedDateTime = dateTime.replaceAll(' ', '');
      videoFolderName ??= "Trimmer";
      videoFileName ??= "flip_$formattedDateTime";

      String path = await _createFolderInAppDocDir(videoFolderName, storageDir);
      String outputPath = '$path$videoFileName.mp4';

      String command = "-i $modifiedFilePath -vf \"$flipDirection\" \"$outputPath\"";

      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSave(outputPath);
          await loadVideo(videoFile: File(outputPath));
          modifiedFilePath = outputPath;
        } else {
          onSave(null);
        }
      });
    } catch (e) {
      onSave(null);
    }
  }

  Future<void> addWatermark({
    required String watermarkPath,
    required int x,
    required int y,
    required Function(String? outputPath) onSave,
    String? videoFolderName,
    String? videoFileName,
    StorageDir? storageDir,
  }) async {
    try {
      String dateTime = DateFormat.yMMMd().addPattern('-').add_Hms().format(
          DateTime.now()).toString();
      String formattedDateTime = dateTime.replaceAll(' ', '');
      videoFolderName ??= "Trimmer";
      videoFileName ??= "watermarked_$formattedDateTime";

      String path = await _createFolderInAppDocDir(videoFolderName, storageDir);
      String outputPath = '$path$videoFileName.mp4';

      String command = "-i $modifiedFilePath -i $watermarkPath -filter_complex \"overlay=$x:$y\" \"$outputPath\"";

      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSave(outputPath);
          await loadVideo(videoFile: File(outputPath));
          modifiedFilePath = outputPath;
        } else {
          onSave(null);
        }
      });
    } catch (e) {
      onSave(null);
    }
  }

  Future<void> addTextToVideo({
    required String text,
    required String fontColor,
    required int fontSize,
    required int x,
    required int y,
    required Function(String? outputPath) onSave,
    String? videoFolderName,
    String? videoFileName,
    StorageDir? storageDir,
  }) async {
    try {
      String dateTime = DateFormat.yMMMd().addPattern('-').add_Hms().format(
          DateTime.now()).toString();
      String formattedDateTime = dateTime.replaceAll(' ', '');
      videoFolderName ??= "Trimmer";
      videoFileName ??= "text_$formattedDateTime";

      String path = await _createFolderInAppDocDir(videoFolderName, storageDir);
      String outputPath = '$path$videoFileName.mp4';

      String command = "-i $modifiedFilePath -vf \"drawtext=text='$text':fontcolor=$fontColor:fontsize=$fontSize:x=$x:y=$y\" \"$outputPath\"";

      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSave(outputPath);
          loadVideo(videoFile: File(outputPath));
        } else {
          onSave(null);
        }
      });
    } catch (e) {
      onSave(null);
    }
  }

  Future<void> changeVideoSpeed({
    required double speedMultiplier,
    required Function(String? outputPath) onSave,
    String? videoFolderName,
    String? videoFileName,
    StorageDir? storageDir,
  }) async {
    try {
      String dateTime = DateFormat.yMMMd().addPattern('-').add_Hms().format(
          DateTime.now()).toString();
      String formattedDateTime = dateTime.replaceAll(' ', '');
      videoFolderName ??= "Trimmer";
      videoFileName ??= "speed_$formattedDateTime";

      String path = await _createFolderInAppDocDir(videoFolderName, storageDir);
      String outputPath = '$path$videoFileName.mp4';

      String command = "-i $modifiedFilePath -vf \"setpts=$speedMultiplier*PTS\" \"$outputPath\"";

      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSave(outputPath);
          await loadVideo(videoFile: File(outputPath));
          modifiedFilePath = outputPath;
        } else {
          onSave(null);
        }
      });
    } catch (e) {
      onSave(null);
    }
  }

  Future<void> resizeVideo({
    required double height,
    required double width,
    required Function(String? outputPath) onSave,
    String? videoFolderName,
    String? videoFileName,
    StorageDir? storageDir,
  }) async {
    try {
      String dateTime = DateFormat.yMMMd().addPattern('-').add_Hms().format(
          DateTime.now()).toString();
      String formattedDateTime = dateTime.replaceAll(' ', '');
      videoFolderName ??= "Trimmer";
      videoFileName ??= "resizeVideo_$formattedDateTime";

      String path = await _createFolderInAppDocDir(videoFolderName, storageDir);
      String outputPath = '$path$videoFileName.mp4';

      String command = "-i $modifiedFilePath -vf scale=$width:$height $outputPath";

      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSave(outputPath);
          await loadVideo(videoFile: File(outputPath));
          modifiedFilePath = outputPath;
        } else {
          onSave(null);
        }
      });
    } catch (e) {
      onSave(null);
    }
  }

  Future<void> applyGrayscaleFilter({
    required int startTime,
    required int duration,
    required Function(String? outputPath) onSave,
    String? videoFolderName,
    String? videoFileName,
    StorageDir? storageDir,
  }) async {
    try {
      String dateTime = DateFormat.yMMMd().addPattern('-').add_Hms().format(
          DateTime.now()).toString();
      String formattedDateTime = dateTime.replaceAll(' ', '');
      videoFolderName ??= "Trimmer";
      videoFileName ??= "grayscale_$formattedDateTime";

      String path = await _createFolderInAppDocDir(videoFolderName, storageDir);
      String outputPath = '$path$videoFileName.mp4';
      String command = "-i $modifiedFilePath -vf \"hue=s=0\" $outputPath";
      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSave(outputPath);
          await loadVideo(videoFile: File(outputPath));
          modifiedFilePath = outputPath;
        } else {
          onSave(null);
        }
      });
    } catch (e) {
      onSave(null);
    }
  }

  Future<void> removeAudio({
    required int startTime,
    required int duration,
    required Function(String? outputPath) onSave,
    String? videoFolderName,
    String? videoFileName,
    StorageDir? storageDir,
  }) async {
    try {
      String dateTime = DateFormat.yMMMd().addPattern('-').add_Hms().format(
          DateTime.now()).toString();
      String formattedDateTime = dateTime.replaceAll(' ', '');
      videoFolderName ??= "Trimmer";
      videoFileName ??= "audioRemoved_$formattedDateTime";

      String path = await _createFolderInAppDocDir(videoFolderName, storageDir);
      String outputPath = '$path$videoFileName.mp4';
      String command = "-i $modifiedFilePath -an $outputPath";
      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSave(outputPath);
          await loadVideo(videoFile: File(outputPath));
          modifiedFilePath = outputPath;
        } else {
          onSave(null);
        }
      });
    } catch (e) {
      onSave(null);
    }
  }

  Future<void> addAudioToVideo({
    required String audioPath,
    required int startTime,
    required int duration,
    required Function(String? outputPath) onSave,
    String? videoFolderName,
    String? videoFileName,
    StorageDir? storageDir,
  }) async {
    try {
      String dateTime = DateFormat.yMMMd().addPattern('-').add_Hms().format(
          DateTime.now()).toString();
      String formattedDateTime = dateTime.replaceAll(' ', '');
      videoFolderName ??= "Trimmer";
      videoFileName ??= "audioAdded_$formattedDateTime";

      String path = await _createFolderInAppDocDir(videoFolderName, storageDir);
      String outputPath = '$path$videoFileName.mp4';
      String command = "-i $modifiedFilePath -i $audioPath -c:v copy -c:a aac $outputPath";
      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSave(outputPath);
          await loadVideo(videoFile: File(outputPath));
          modifiedFilePath = outputPath;
        } else {
          onSave(null);
        }
      });
    } catch (e) {
      onSave(null);
    }
  }

  Future<void> mergeVideos({
    required List<String> inputPaths,
    required Function(String? outputPath) onSave,
    String? videoFolderName,
    String? videoFileName,
    StorageDir? storageDir,
  }) async {
    try {
      String dateTime = DateFormat.yMMMd().addPattern('-').add_Hms().format(
          DateTime.now()).toString();
      String formattedDateTime = dateTime.replaceAll(' ', '');
      videoFolderName ??= "Trimmer";
      videoFileName ??= "merged_$formattedDateTime";

      String path = await _createFolderInAppDocDir(videoFolderName, storageDir);
      String outputPath = '$path$videoFileName.mp4';

      String inputs = inputPaths.map((path) => "-i $path").join(' ');
      String filterComplex = inputPaths
          .asMap()
          .entries
          .map((e) => "[${e.key}:v:0][${e.key}:a:0]")
          .join('') + "concat=n=${inputPaths.length}:v=1:a=1[outv][outa]";
      String command = "$inputs -filter_complex \"$filterComplex\" -map \"[outv]\" -map \"[outa]\" \"$outputPath\"";

      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSave(outputPath);
          loadVideo(videoFile: File(outputPath));
        } else {
          onSave(null);
        }
      });
    } catch (e) {
      onSave(null);
    }
  }

  Future<double> saveEditedVideo({
    required Map<String, dynamic> data,
    required Function(String? outputPath) onSave,
    required Function(double progress) onProgress,
    required BuildContext context,
  }) async {
    try{
      final String? inputPath = currentVideoFile?.path;
      String outputPath = "";

    // Create default output path if not provided
    if (outputPath.isEmpty) {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String outputFileName = 'edited_video_${DateTime
          .now()
          .millisecondsSinceEpoch}.mp4';
      outputPath = '${directory.path}/$outputFileName';
    }

    // Get video dimensions from the VideoPlayerController
    final VideoPlayerController videoPlayerController = _videoPlayerController!;
    final videoWidth = videoPlayerController.value.size.width.toInt();
    final videoHeight = videoPlayerController.value.size.height.toInt();

    // Initialize the FFmpeg command
    String command = '-i $inputPath';

    // Add trimming
    if (data['trimmer'] != null) {
      double startTrim = data['trimmer']['startValue'];
      double endTrim = data['trimmer']['endValue'];
      command += ' -ss $startTrim -to $endTrim';
    }

    // Add cropping
    if (data['crop'] != null) {
      double wr = data['crop']['wr'];
      double wl = data['crop']['wl'];
      double ll = data['crop']['ll'];
      double lr = data['crop']['lr'];

      int cropWidth = (videoWidth - wr - wl).toInt();
      int cropHeight = (videoHeight - lr - ll).toInt();
      int x = wl.toInt();
      int y = ll.toInt();

      command += ' -vf "crop=$cropWidth:$cropHeight:$x:$y"';
    }

    // Add scaling
    if (data['scale'] != null) {
      String scale = data['scale'].toString();
      command += ' -vf "scale=$scale"';
    }

    // Add rotation
    if (data['rotation'] != null) {
      double rotation = data['rotation']['value'];
      command += ' -vf "rotate=${rotation}*PI/180"';
    }

    // Add text overlay
    if (data['addText'] != null) {
      Text? overlayText = data['addText'] as Text?;
      if (overlayText != null) {
        String textOverlay = overlayText.data ?? '';
        TextStyle? style = overlayText.style;

        // Extract text style properties
        String fontColor = style?.color?.toHex() ?? 'white';
        String fontSize = style?.fontSize?.toString() ?? '24';
        String fontWeight = style?.fontWeight?.toString() ?? 'normal';
        String fontStyle = style?.fontStyle == FontStyle.italic
            ? 'italic'
            : 'normal';
        String? backgroundColor = style?.background?.color
            .toHex(); // Get background color or null if not set

        // Format text style for FFmpeg
        String textStyle = "fontfile=/path/to/font.ttf:fontsize=$fontSize:fontcolor=$fontColor:fontweight=$fontWeight:fontstyle=$fontStyle";

        // Include background color if specified
        if (backgroundColor != null) {
          textStyle += ":box=1:boxcolor=$backgroundColor:boxborderw=5";
        }

        command += ' -vf "drawtext=text=\'$textOverlay\':$textStyle:x=10:y=10"';
      }
    }

    // Add brightness
    if (data['brightness'] != null) {
      double brightness = data['brightness']['value'];
      command += ' -vf "eq=brightness=$brightness"';
    }

    // Add saturation
    if (data['saturation'] != null) {
      double saturation = data['saturation']['value'];
      command += ' -vf "eq=saturation=$saturation"';
    }

    // Add audio trimming if applicable
    if (data['mTrimmer'] != null) {
      double audioStart = data['mTrimmer']['startValue'];
      double audioEnd = data['mTrimmer']['endValue'];
      String audioPath = data['file'] as String;

      // Extract the audio trim command
      String audioTrimCommand = '-i $audioPath -ss $audioStart -to $audioEnd -c:a aac -b:a 192k -y /path/to/trimmed_audio.aac';

      // Add the audio trim command to the main command
      command += ' -i /path/to/trimmed_audio.aac -c:v copy -c:a aac -b:a 192k';
    }

    // Add fade effect
    if (data['fade'] != null) {
      double fade = data['fade']['value'];
      command += ' -vf "fade=t=in:st=0:d=$fade,fade=t=out:st=10:d=$fade"';
    }

    // Add video speed adjustment
    if (data['videospeed'] != null) {
      double speed = data['videospeed']['value'];
      command += ' -filter:v "setpts=PTS/$speed"';
    }

    // Finalize command with the output path
    command += ' $outputPath';

    // Execute the command with FFmpegKit
    final session = await FFmpegKit.executeAsync(
      command,
          (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          onSave(outputPath);
        } else {
          onSave(null);
        }
      },
          (log) {
        // Extract progress from the log message
        final progressMatch = RegExp(r'(\d+)%').firstMatch(log.getMessage());
        if (progressMatch != null) {
          final progress = double.parse(progressMatch.group(1)!) / 100.0;
          onProgress(progress);
        }
      },
    );

    // Await the session to get the return code
    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      return 1.0; // 100% progress
    } else {
      return 0.0; // 0% progress indicating failure
    }
  }catch (e){
  showDialog(context: context, builder: (context){
  return AlertDialog(
  content: Text(e.toString()),
  );
  });
  return 0.0;
  }
}






// Example of the editVideo function, using the new structure


  Future<bool> videoPlaybackControl({
    required double startValue,
    required double endValue,
  }) async {
    if (isVideoPlayerInitialized) {
      if (_videoPlayerController!.value.isPlaying) {
        await _videoPlayerController!.pause();
        return false;
      } else {
        if (_videoPlayerController!.value.position.inMilliseconds >=
            endValue.toInt()) {
          await _videoPlayerController!
              .seekTo(Duration(milliseconds: startValue.toInt()));
          await _videoPlayerController!.play();
          return true;
        } else {
          await _videoPlayerController!.play();
          return true;
        }
      }
    } else {
      debugPrint('VideoPlayerController is not initialized.');
      return false;
    }
  }

  void dispose() {
    _controller.close();
    _videoPlayerController?.dispose();
  }
}
