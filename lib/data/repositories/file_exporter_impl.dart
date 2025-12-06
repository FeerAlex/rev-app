import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../../domain/repositories/file_exporter.dart';

/// Реализация FileExporter с использованием share_plus
class FileExporterImpl implements FileExporter {
  @override
  Future<bool> exportFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final xFile = XFile(filePath);
      await Share.shareXFiles([xFile], text: 'Экспорт базы данных Rev App');
      return true;
    } catch (e) {
      return false;
    }
  }
}

