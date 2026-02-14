import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  // Сделать фото камерой
  Future<File?> takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo == null) return null;
      return File(photo.path);
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  // Выбрать фото из галереи
  Future<File?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Распознать текст на фото
  Future<String> recognizeText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      // Собираем весь текст
      String text = recognizedText.text;

      return text.trim();
    } catch (e) {
      debugPrint('Error recognizing text: $e');
      throw Exception('Не удалось распознать текст: $e');
    }
  }

  // Очистить ресурсы
  void dispose() {
    _textRecognizer.close();
  }
}
