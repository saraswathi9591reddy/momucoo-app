import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// Picked image: display name plus a path ML Kit can read.
class PickedImage {
  const PickedImage(this.name, this.path);
  final String name, path;
}

/// Seam over image_picker + ML Kit so widget tests can inject fakes.
abstract class OcrService {
  Future<PickedImage?> pick(ImageSource source);
  Future<String> recognize(String path);
}

class MlKitOcrService implements OcrService {
  const MlKitOcrService();

  @override
  Future<PickedImage?> pick(ImageSource source) async {
    final f = await ImagePicker().pickImage(source: source, imageQuality: 95);
    return f == null ? null : PickedImage(f.name, f.path);
  }

  @override
  Future<String> recognize(String path) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(InputImage.fromFilePath(path));
      return result.text;
    } finally {
      await recognizer.close();
    }
  }
}
