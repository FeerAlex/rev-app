import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraScanPage extends StatefulWidget {
  const CameraScanPage({super.key});

  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Камера недоступна'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка инициализации камеры: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Удаляет мелкие шумы из бинаризованного изображения
  img.Image _removeNoise(img.Image image) {
    final result = img.Image(width: image.width, height: image.height);
    
    // Проходим по всем пикселям, кроме краев
    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        final center = image.getPixel(x, y);
        final centerValue = center.r;
        
        // Считаем количество соседей с таким же значением
        int sameNeighbors = 0;
        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) continue;
            final neighbor = image.getPixel(x + dx, y + dy);
            if (neighbor.r == centerValue) {
              sameNeighbors++;
            }
          }
        }
        
        // Если у пикселя меньше 3 соседей с таким же значением - это шум, удаляем
        // (меняем на противоположное значение)
        if (sameNeighbors < 3) {
          final noiseValue = centerValue == 0 ? 255 : 0;
          result.setPixelRgba(x, y, noiseValue, noiseValue, noiseValue, 255);
        } else {
          result.setPixelRgba(x, y, centerValue, centerValue, centerValue, 255);
        }
      }
    }
    
    // Копируем края без изменений
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        if (x == 0 || x == image.width - 1 || y == 0 || y == image.height - 1) {
          final pixel = image.getPixel(x, y);
          final value = pixel.r;
          result.setPixelRgba(x, y, value, value, value, 255);
        }
      }
    }
    
    return result;
  }

  /// Улучшает изображение для OCR: увеличивает контрастность, применяет бинаризацию
  img.Image _enhanceImageForOCR(img.Image image) {
    // 1. Конвертируем в grayscale (если еще не)
    img.Image processed = img.grayscale(image);

    // 2. Применяем легкое размытие для удаления шума (Gaussian blur)
    processed = img.gaussianBlur(processed, radius: 1);

    // 3. Увеличиваем контрастность
    processed = img.adjustColor(
      processed,
      contrast: 1.4, // Увеличиваем контраст на 40%
      brightness: 1.0, // Без изменения яркости
    );

    // 4. Вычисляем оптимальный порог бинаризации (Otsu threshold)
    // Собираем гистограмму яркостей
    final histogram = List<int>.filled(256, 0);
    
    for (int y = 0; y < processed.height; y++) {
      for (int x = 0; x < processed.width; x++) {
        final pixel = processed.getPixel(x, y);
        final gray = ((pixel.r + pixel.g + pixel.b) / 3).round().clamp(0, 255);
        histogram[gray]++;
      }
    }

    // Вычисляем Otsu threshold (оптимальный порог для бинаризации)
    double bestThreshold = 128;
    double maxVariance = 0;
    
    for (int t = 1; t < 255; t++) {
      int w0 = 0; // Вес класса 0 (темные пиксели)
      int w1 = 0; // Вес класса 1 (светлые пиксели)
      double sum0 = 0;
      double sum1 = 0;
      
      for (int i = 0; i <= t; i++) {
        w0 += histogram[i];
        sum0 += i * histogram[i];
      }
      for (int i = t + 1; i < 256; i++) {
        w1 += histogram[i];
        sum1 += i * histogram[i];
      }
      
      if (w0 == 0 || w1 == 0) continue;
      
      final mean0 = sum0 / w0;
      final mean1 = sum1 / w1;
      final variance = w0 * w1 * (mean0 - mean1) * (mean0 - mean1);
      
      if (variance > maxVariance) {
        maxVariance = variance;
        bestThreshold = t.toDouble();
      }
    }

    final threshold = bestThreshold.round();

    // 5. Применяем бинаризацию с вычисленным порогом
    for (int y = 0; y < processed.height; y++) {
      for (int x = 0; x < processed.width; x++) {
        final pixel = processed.getPixel(x, y);
        final gray = ((pixel.r + pixel.g + pixel.b) / 3).round();
        
        // Стандартная бинаризация
        final binaryValue = gray < threshold ? 0 : 255;
        processed.setPixelRgba(x, y, binaryValue, binaryValue, binaryValue, 255);
      }
    }

    // 6. Удаляем мелкие шумы (морфологическая операция - открытие)
    // Удаляем маленькие белые точки (шум) на черном фоне
    processed = _removeNoise(processed);

    // 7. Увеличиваем размер, если изображение слишком маленькое (для лучшего OCR)
    if (processed.width < 300 || processed.height < 300) {
      final scale = 300 / (processed.width < processed.height ? processed.width : processed.height);
      processed = img.copyResize(
        processed,
        width: (processed.width * scale).round(),
        height: (processed.height * scale).round(),
        interpolation: img.Interpolation.linear,
      );
    }
    return processed;
  }

  Future<String?> _captureAndCrop() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      // Делаем снимок
      final XFile imageFile = await _controller!.takePicture();

      // Получаем размеры preview камеры (нужно до проверки ориентации)
      final previewSize = _controller!.value.previewSize!;

      // Читаем изображение
      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        return null;
      }

      // Получаем ориентацию устройства
      final deviceOrientation = MediaQuery.of(context).orientation;
      final isPortrait = deviceOrientation == Orientation.portrait;

      // Проверяем ориентацию preview и изображения
      // Если preview шире, чем выше - это landscape
      final previewIsLandscape = previewSize.width > previewSize.height;
      final imageIsLandscape = originalImage.width > originalImage.height;


      // Если устройство в portrait, а изображение в landscape - поворачиваем изображение
      if (isPortrait && imageIsLandscape) {
        // Поворачиваем на 90 градусов против часовой стрелки
        originalImage = img.copyRotate(originalImage, angle: 90);
      }

      // Если устройство в portrait, а preview в landscape - нужно учесть поворот
      // Preview отображается повернутым, но previewSize остается в landscape
      final effectivePreviewWidth = isPortrait && previewIsLandscape 
          ? previewSize.height  // После поворота ширина и высота меняются местами
          : previewSize.width;
      final effectivePreviewHeight = isPortrait && previewIsLandscape
          ? previewSize.width
          : previewSize.height;
      
      final previewAspectRatio = effectivePreviewHeight / effectivePreviewWidth;

      // Размеры экрана
      final screenSize = MediaQuery.of(context).size;
      final screenWidth = screenSize.width;
      final screenHeight = screenSize.height;

      // Размеры рамки (80% ширины экрана, 16:9)
      final frameWidth = screenWidth * 0.8;
      final frameHeight = frameWidth / (16 / 9);

      // Позиция рамки (по центру экрана)
      final frameLeft = (screenWidth - frameWidth) / 2;
      final frameTop = (screenHeight - frameHeight) / 2;

      // Вычисляем, как preview отображается на экране с AspectRatio
      // Preview обернут в AspectRatio и Center, поэтому он может быть меньше экрана
      final screenAspectRatio = screenHeight / screenWidth;
      double previewDisplayWidth, previewDisplayHeight, previewOffsetX, previewOffsetY;

      if (previewAspectRatio > screenAspectRatio) {
        // Preview выше экрана - занимает всю высоту, обрезается по бокам
        previewDisplayHeight = screenHeight;
        previewDisplayWidth = screenHeight / previewAspectRatio;
        previewOffsetX = (screenWidth - previewDisplayWidth) / 2;
        previewOffsetY = 0;
      } else {
        // Preview шире экрана - занимает всю ширину, обрезается сверху/снизу
        previewDisplayWidth = screenWidth;
        previewDisplayHeight = screenWidth * previewAspectRatio;
        previewOffsetX = 0;
        previewOffsetY = (screenHeight - previewDisplayHeight) / 2;
      }

      // Координаты рамки относительно отображаемого preview (с учетом смещения)
      final relativeFrameLeft = frameLeft - previewOffsetX;
      final relativeFrameTop = frameTop - previewOffsetY;

      // Масштаб между отображаемым preview и эффективными размерами preview
      final previewScaleX = effectivePreviewWidth / previewDisplayWidth;
      final previewScaleY = effectivePreviewHeight / previewDisplayHeight;

      // Координаты рамки в эффективных preview координатах
      final frameXInPreview = relativeFrameLeft * previewScaleX;
      final frameYInPreview = relativeFrameTop * previewScaleY;
      final frameWidthInPreview = frameWidth * previewScaleX;
      final frameHeightInPreview = frameHeight * previewScaleY;

      // Масштаб между эффективными preview размерами и реальным изображением
      // (после поворота, если был)
      final imageScaleX = originalImage.width / effectivePreviewWidth;
      final imageScaleY = originalImage.height / effectivePreviewHeight;

      // Координаты обрезки в реальном изображении
      final cropX = (frameXInPreview * imageScaleX).round().clamp(0, originalImage.width);
      final cropY = (frameYInPreview * imageScaleY).round().clamp(0, originalImage.height);
      final cropWidth = (frameWidthInPreview * imageScaleX).round().clamp(0, originalImage.width - cropX);
      final cropHeight = (frameHeightInPreview * imageScaleY).round().clamp(0, originalImage.height - cropY);


      // Обрезаем изображение
      img.Image croppedImage = img.copyCrop(
        originalImage,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );

      // Предобработка изображения для улучшения OCR
      croppedImage = _enhanceImageForOCR(croppedImage);

      // Сохраняем во временный файл
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final croppedFilePath = path.join(tempDir.path, 'cropped_$timestamp.jpg');

      final croppedBytes = Uint8List.fromList(img.encodeJpg(croppedImage, quality: 95));
      final croppedFile = File(croppedFilePath);
      await croppedFile.writeAsBytes(croppedBytes);

      // Удаляем оригинальный файл
      try {
        await File(imageFile.path).delete();
      } catch (_) {}

      return croppedFilePath;
    } catch (e) {
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Размеры рамки (80% ширины экрана, 16:9)
    final frameWidth = screenWidth * 0.8;
    final frameHeight = frameWidth / (16 / 9);

    // Позиция рамки (по центру)
    final frameLeft = (screenWidth - frameWidth) / 2;
    final frameTop = (screenHeight - frameHeight) / 2;

    // Получаем aspect ratio preview для правильного отображения
    final previewSize = _controller!.value.previewSize!;
    final previewAspectRatio = previewSize.height / previewSize.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview с правильным aspect ratio
          Center(
            child: AspectRatio(
              aspectRatio: previewAspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
          // Overlay с затемнением
          Positioned.fill(
            child: CustomPaint(
              painter: _OverlayPainter(
                frameLeft: frameLeft,
                frameTop: frameTop,
                frameWidth: frameWidth,
                frameHeight: frameHeight,
              ),
            ),
          ),
          // Рамка
          Positioned(
            left: frameLeft,
            top: frameTop,
            child: Container(
              width: frameWidth,
              height: frameHeight,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
          // Кнопка "Снять"
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _isCapturing
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : FloatingActionButton(
                      onPressed: () async {
                        final croppedPath = await _captureAndCrop();
                        if (mounted) {
                          Navigator.pop(context, croppedPath);
                        }
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.camera_alt, color: Colors.black),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final double frameLeft;
  final double frameTop;
  final double frameWidth;
  final double frameHeight;

  _OverlayPainter({
    required this.frameLeft,
    required this.frameTop,
    required this.frameWidth,
    required this.frameHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Рисуем затемнение вокруг рамки
    // Верхняя часть
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, frameTop),
      paint,
    );
    // Нижняя часть
    canvas.drawRect(
      Rect.fromLTWH(0, frameTop + frameHeight, size.width, size.height - frameTop - frameHeight),
      paint,
    );
    // Левая часть
    canvas.drawRect(
      Rect.fromLTWH(0, frameTop, frameLeft, frameHeight),
      paint,
    );
    // Правая часть
    canvas.drawRect(
      Rect.fromLTWH(
        frameLeft + frameWidth,
        frameTop,
        size.width - frameLeft - frameWidth,
        frameHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_OverlayPainter oldDelegate) {
    return oldDelegate.frameLeft != frameLeft ||
        oldDelegate.frameTop != frameTop ||
        oldDelegate.frameWidth != frameWidth ||
        oldDelegate.frameHeight != frameHeight;
  }
}

