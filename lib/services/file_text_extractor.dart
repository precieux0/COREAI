import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:path/path.dart' as p;

class FileTextExtractor {
  static Future<String> extract(PlatformFile file) async {
    final ext = p.extension(file.name).toLowerCase();
    final path = file.path!;

    switch (ext) {
      case '.txt':
        return File(path).readAsStringSync();
      case '.pdf':
        // Utilisation de pdfrx au lieu de pdf_text
        final document = await PdfDocument.openFile(path);
        final text = await document.extractText();
        await document.close();
        return text.trim();
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.bmp':
        return await _ocrImage(path);
      default:
        final bytes = File(path).readAsBytesSync();
        return '[Fichier binaire encodé en base64]\n${base64Encode(bytes)}';
    }
  }

  static Future<String> _ocrImage(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    return recognizedText.text;
  }
}