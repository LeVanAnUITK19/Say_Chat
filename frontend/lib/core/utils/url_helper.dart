import 'package:flutter/foundation.dart';

/// Rewrite bất kỳ URL ảnh nào về đúng base URL của API hiện tại.
/// Giải quyết vấn đề URL được lưu trong DB với IP nội bộ (192.168.x.x)
/// nhưng client đang chạy trên host khác (localhost, domain...).
String resolveMediaUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.isEmpty) return '';

  // Nếu là relative path, ghép với base URL
  if (rawUrl.startsWith('/')) {
    return '${_apiBaseUrl()}$rawUrl';
  }

  // Nếu là absolute URL, thay thế host bằng host hiện tại của API
  try {
    final uri = Uri.parse(rawUrl);
    final apiUri = Uri.parse(_apiBaseUrl());
    final rewritten = uri.replace(
      scheme: apiUri.scheme,
      host: apiUri.host,
      port: apiUri.port,
    );
    return rewritten.toString();
  } catch (_) {
    return rawUrl;
  }
}

String _apiBaseUrl() {
  
  return 'https://say-chat.onrender.com';
}
