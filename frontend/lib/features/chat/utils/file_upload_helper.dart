import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';
import '../data/model/message.dart';

class FileUploadHelper {
  final Dio _dio = DioClient().dio;

  /// Upload file và trả về MessageAttachment
  Future<MessageAttachment> uploadFile({
    required File file,
    required String type, // "image", "audio", "sticker", "video", "file"
    Map<String, dynamic>? metadata,
  }) async {
    try {
      print('📤 Starting upload for file: ${file.path}');
      print('📤 File exists: ${await file.exists()}');
      
      String fileName = file.path.split('/').last;
      print('📤 File name: $fileName');
      
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'type': type,
      });
      
      print('📤 FormData created, sending request...');

      // KHÔNG set Content-Type thủ công, để Dio tự động set với boundary
      final response = await _dio.post(
        '/api/upload',
        data: formData,
      );
      
      print('📤 Response received: ${response.statusCode}');
      print('📤 Response data: ${response.data}');
      
      if (response.data == null || response.data['url'] == null) {
        throw Exception('Server không trả về URL');
      }
      
      return MessageAttachment(
        type: type,
        url: response.data['url'] as String,
        metadata: metadata,
      );
    } catch (e) {
      print('❌ Upload error details: $e');
      if (e is DioException) {
        print('❌ DioException type: ${e.type}');
        print('❌ Response: ${e.response?.data}');
      }
      throw Exception('Upload file thất bại: $e');
    }
  }

  /// Upload nhiều file cùng lúc
  Future<List<MessageAttachment>> uploadMultipleFiles({
    required List<File> files,
    required String type,
  }) async {
    List<MessageAttachment> attachments = [];
    
    for (var file in files) {
      try {
        final attachment = await uploadFile(file: file, type: type);
        attachments.add(attachment);
      } catch (e) {
        print('Error uploading file ${file.path}: $e');
      }
    }
    
    return attachments;
  }
}
