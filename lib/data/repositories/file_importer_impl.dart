import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../domain/repositories/file_importer.dart';

/// Реализация FileImporter с использованием file_picker
class FileImporterImpl implements FileImporter {
  @override
  Future<String?> importFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

      // Пользователь отменил выбор - возвращаем null
      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.single;
      
      // Проверяем расширение файла
      final fileName = file.name.toLowerCase();
      if (!fileName.endsWith('.db')) {
        throw Exception('Выбранный файл не является файлом базы данных (.db)');
      }
      
      // Если есть прямой путь и файл доступен, используем его
      if (file.path != null) {
        final filePath = file.path!;
        final fileObj = File(filePath);
        if (await fileObj.exists()) {
          return filePath;
        }
      }
      
      // Если путь недоступен (например, файл из Google Drive),
      // используем bytes и сохраняем во временный файл
      if (file.bytes != null && file.bytes!.isNotEmpty) {
        final tempDir = await getTemporaryDirectory();
        final tempFilePath = path.join(tempDir.path, 'imported_db_${DateTime.now().millisecondsSinceEpoch}.db');
        final tempFile = File(tempFilePath);
        await tempFile.writeAsBytes(file.bytes!);
        
        // Проверяем, что файл успешно создан
        if (await tempFile.exists()) {
          return tempFilePath;
        } else {
          throw Exception('Не удалось создать временный файл для импорта');
        }
      }
      
      // Если нет ни пути, ни bytes, выбрасываем исключение
      throw Exception('Не удалось получить файл для импорта. Убедитесь, что файл доступен.');
  }
}

