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

  // Исправление частых ошибок OCR
  String _fixCommonOcrErrors(String text) {
    // Убираем лишние пробелы
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Исправляем частые ошибки с цифрами
    text = text.replaceAll(RegExp(r'[lI](?=\s*=)'), '1'); // l = → 1 =
    text = text.replaceAll(RegExp(r'O(?=\s*\d)'), '0'); // O2 → 02
    text = text.replaceAll(RegExp(r'o(?=\s*\d)'), '0'); // o2 → 02
    text = text.replaceAll(RegExp(r'S(?=\s*x)'), '5'); // Sx → 5x
    text = text.replaceAll(RegExp(r'Z(?=\s*x)'), '2'); // Zx → 2x
    text = text.replaceAll(RegExp(r'l(?=\d)'), '1'); // l3 → 13
    text = text.replaceAll(RegExp(r'I(?=\d)'), '1'); // I3 → 13

    // Исправляем буквы вместо цифр в конце чисел
    text = text.replaceAll(RegExp(r'(\d+)[lI]'), r'$11'); // 2l → 21
    text = text.replaceAll(RegExp(r'(\d+)O'), r'${1}0'); // 2O → 20
    text = text.replaceAll(RegExp(r'(\d+)S'), r'${1}5'); // 2S → 25

    // Исправляем операторы
    text =
        text.replaceAll(RegExp(r'\s*х\s*'), ' x '); // русская х → латинская x
    text =
        text.replaceAll(RegExp(r'\s*Х\s*'), ' x '); // русская Х → латинская x
    text = text.replaceAll(RegExp(r'\s*:\s*'), ' : '); // пробелы вокруг :

    // Исправляем знаки равенства
    text = text.replaceAll(RegExp(r'\s*=\s*'), ' = '); // пробелы вокруг =
    text = text.replaceAll(RegExp(r'\s*\+\s*'), ' + '); // пробелы вокруг +
    text = text.replaceAll(RegExp(r'\s*-\s*'), ' - '); // пробелы вокруг -

    // Убираем двойные пробелы снова
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }

  // Убираем лишний текст (watermarks, URLs, названия сайтов)
  String _removeWatermarks(String text) {
    // Убираем URLs
    text = text.replaceAll(RegExp(r'http[s]?://\S+'), '');
    text = text.replaceAll(RegExp(r'www\.\S+'), '');

    // Убираем распространённые watermarks
    text = text.replaceAll(RegExp(r'ppt\s+Online', caseSensitive: false), '');
    text = text.replaceAll(RegExp(r'Яндекс', caseSensitive: false), '');
    text = text.replaceAll(
        RegExp(r'класс по математике', caseSensitive: false), '');
    text = text.replaceAll(
        RegExp(r'[A-Za-z]{2,}\.[A-Z][a-z]', caseSensitive: false),
        ''); // Типа Fkniqa.Ru

    // Убираем строки с большим количеством странных символов
    List<String> lines = text.split('\n');
    lines = lines.where((line) {
      // Считаем буквы латиницы и кириллицы
      int latinCount = RegExp(r'[A-Z]').allMatches(line).length;
      int totalChars = line.replaceAll(RegExp(r'\s'), '').length;

      // Если больше 50% заглавных латинских букв = вероятно watermark
      if (totalChars > 0 && latinCount / totalChars > 0.5) {
        return false;
      }
      return line.trim().isNotEmpty;
    }).toList();

    return lines.join('\n').trim();
  }

  // Распознать текст на фото
// Распознать текст на фото
  Future<String> recognizeText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      // Собираем весь текст
      String text = recognizedText.text;

      text = _removeWatermarks(text);
      // ИСПРАВЛЯЕМ ЧАСТЫЕ ОШИБКИ ← ДОБАВИЛИ!
      text = _fixCommonOcrErrors(text);

      return text.trim();
    } catch (e) {
      // ignore: avoid_print
      print('Error recognizing text: $e');
      throw Exception('Не удалось распознать текст: $e');
    }
  }

  // Очистить ресурсы
  void dispose() {
    _textRecognizer.close();
  }
}
