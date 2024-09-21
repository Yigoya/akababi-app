import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

Map<String, dynamic> selectedMedia = {};

class MediaProcessing {
  final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();

  Future<void> resizeImage(File inputImage) async {
    final imageBytes = inputImage.readAsBytesSync();
    img.Image image = img.decodeImage(imageBytes)!;

    // Resize the image
    img.Image resized = img.copyResize(image, width: 600);

    // Save the resized image
    final directory = await getApplicationDocumentsDirectory();
    final outputPath = '${directory.path}/resized_image.jpg';
    File resizedImageFile = File(outputPath)
      ..writeAsBytesSync(img.encodeJpg(resized));

    selectedMedia["filePath"] = resizedImageFile.path;
  }

  Future<File> cropImage(
      File inputImage, int x, int y, int width, int height) async {
    final imageBytes = inputImage.readAsBytesSync();
    img.Image image = img.decodeImage(imageBytes)!;

    // Crop the image
    img.Image cropped =
        img.copyCrop(image, x: x, y: y, width: width, height: height);

    // Save the cropped image
    final directory = await getApplicationDocumentsDirectory();
    final outputPath = '${directory.path}/cropped_image.jpg';
    File croppedImageFile = File(outputPath)
      ..writeAsBytesSync(img.encodeJpg(cropped));

    return croppedImageFile;
  }

  Future<File> applyFilter(File inputImage) async {
    final imageBytes = inputImage.readAsBytesSync();
    img.Image image = img.decodeImage(imageBytes)!;

    // Apply a brightness filter
    img.Image brightenedImage = img.adjustColor(image, brightness: 0.2);

    // Save the filtered image
    final directory = await getApplicationDocumentsDirectory();
    final outputPath = '${directory.path}/filtered_image.jpg';
    File filteredImageFile = File(outputPath)
      ..writeAsBytesSync(img.encodeJpg(brightenedImage));

    return filteredImageFile;
  }

  Future<String> compressVideo(String inputPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final outputPath = '${directory.path}/compressed_video.mp4';

    // FFmpeg command for compressing the video
    final command = '-i $inputPath -vcodec libx264 -crf 28 $outputPath';

    await _ffmpeg.execute(command).then((rc) {
      if (rc == 0) {
        print('Compression successful');
      } else {
        print('Error during compression');
      }
    });

    return outputPath;
  }

  Future<String> trimVideo(String inputPath, double start, double end) async {
    final directory = await getApplicationDocumentsDirectory();
    final outputPath = '${directory.path}/trimmed_video.mp4';

    // FFmpeg command for trimming the video
    final command = '-i $inputPath -ss $start -to $end -c copy $outputPath';

    await _ffmpeg.execute(command).then((rc) {
      if (rc == 0) {
        print('Video trimmed successfully');
      } else {
        print('Error during trimming');
      }
    });

    return outputPath;
  }

  Future<String> addWatermark(String videoPath, String watermarkPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final outputPath = '${directory.path}/watermarked_video.mp4';

    // FFmpeg command for adding a watermark to the video
    final command =
        '-i $videoPath -i $watermarkPath -filter_complex "overlay=10:10" $outputPath';

    await _ffmpeg.execute(command).then((rc) {
      if (rc == 0) {
        print('Watermark added successfully');
      } else {
        print('Error adding watermark');
      }
    });

    return outputPath;
  }

  Future<String> convertVideoFormat(String inputPath, String format) async {
    final directory = await getApplicationDocumentsDirectory();
    final outputPath = '${directory.path}/converted_video.$format';

    // FFmpeg command for converting video format
    final command = '-i $inputPath $outputPath';

    await _ffmpeg.execute(command).then((rc) {
      if (rc == 0) {
        print('Video format conversion successful');
      } else {
        print('Error during format conversion');
      }
    });

    return outputPath;
  }

  Future<void> processMedia(String filePath, String mediaType) async {
    if (mediaType == 'video') {
      final compressedVideo = await compressVideo(filePath);
      final thumbnail = await createVideoThumbnail(compressedVideo);
    } else if (mediaType == 'image') {
      final resizedImage = await resizeImage(File(filePath));
    }
  }

  Future<File> compressImage(File inputImage, {int quality = 85}) async {
    // Read image as bytes
    final imageBytes = inputImage.readAsBytesSync();
    // Decode image using the image package
    img.Image image = img.decodeImage(imageBytes)!;

    // Compress the image by reducing the quality
    List<int> compressedBytes = img.encodeJpg(image, quality: quality);

    // Save compressed image to a file
    final directory = await getTemporaryDirectory();
    final compressedImagePath = '${directory.path}/compressed_image.jpg';
    final compressedImageFile = File(compressedImagePath)
      ..writeAsBytesSync(compressedBytes);

    return compressedImageFile;
  }

  Future<File?> createVideoThumbnail(String videoPath) async {
    // final directory = await getTemporaryDirectory();
    // final thumbnailPath = await VideoThumbnail.thumbnailFile(
    //   video: videoPath,
    //   thumbnailPath: directory.path,
    //   imageFormat: ImageFormat.JPEG,
    //   maxHeight: 150, // Specify the maximum height of the thumbnail
    //   quality: 75, // Set thumbnail quality
    // );

    // if (thumbnailPath != null) {
    //   return File(thumbnailPath);
    // }
    // return null;
  }
}

class MediaPicker {
  Future<void> pickImage(ImageSource imageSource) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: imageSource);

    if (image != null) {
      String fileExtension = extension(image.path);

      selectedMedia = {
        "filePath": image.path,
        "fileType": 'image',
        "mediaType": 'image $fileExtension'
      };
    }
  }

  Future<void> pickVideo(ImageSource imageSource) async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: imageSource);
    if (video != null) {
      String fileExtension = extension(video.path);

      selectedMedia = {
        "filePath": video.path,
        "fileType": 'video',
        "mediaType": 'video $fileExtension'
      };
    }
  }

  Future<void> pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      String fileExtension = extension(file.path!);
      selectedMedia = {
        "filePath": file.path!,
        "fileType": 'audio',
        "mediaType": 'audio $fileExtension',
      };
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      String fileExtension = extension(file.path!);
      selectedMedia = {
        "filePath": file.path!,
        "fileType": 'file',
        "mediaType": 'application $fileExtension'
      };
    }
  }
}
