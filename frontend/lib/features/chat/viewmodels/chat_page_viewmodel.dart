import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../data/repositories/message_repository.dart';
import '../data/repositories/reaction_repository.dart';
import '../data/model/message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../utils/file_upload_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/services/socket_service.dart';

// Conditional import cho audio recorder
import 'package:flutter_sound/flutter_sound.dart'
    if (dart.library.html) '../utils/audio_recorder_stub.dart';

class ChatPageViewmodel extends ChangeNotifier {
  final BuildContext context;
  final String conversationId;
  final MessageRepository _messageRepository = MessageRepository();
  final ReactionRepository _reactionRepository = ReactionRepository();
  final FileUploadHelper _fileUploadHelper = FileUploadHelper();
  final ImagePicker _imagePicker = ImagePicker();
  FlutterSoundRecorder? _audioRecorder; // Nullable cho web
  final String? recipientId;
  final String type;
  final SocketService _socketService = SocketService();

  ChatPageViewmodel({
    required this.context,
    required this.conversationId,
    required this.recipientId,
    required this.type,
  }) {
    if (!kIsWeb) {
      _initRecorder();
    }
    loadMessages();
    loadCurrentUserId();
    _initSocket();
  }

  bool _isActive = true;

  void setActive(bool active) {
    _isActive = active;
    if (active) {
      // Reload khi quay lại để lấy tin nhắn bị miss lúc inactive
      loadMessages();
    }
  }

  void _initSocket() {
    _socketService.joinConversation(conversationId);
    _socketService.onNewMessageForConversation(conversationId, (data) {
      if (!_isActive)
        return; // Page không visible → bỏ qua, sẽ reload khi active lại
      final msgJson = data['message'] as Map<String, dynamic>?;
      if (msgJson == null) return;
      final newMsg = Message.fromJson(msgJson);
      if (newMsg.conversationId != conversationId) return;
      final exists = _messages.any((m) => m.id == newMsg.id);
      if (!exists) {
        _messages = [..._messages, newMsg];
        notifyListeners();
        _scrollToBottom();
      }
    });
  }

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  String? _recordingPath;

  List<Message> _messages = [];
  List<Message> get messages => _messages;

  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  String _username = '';
  String get username => _username;

  Future<void> _initRecorder() async {
    if (!kIsWeb) {
      _audioRecorder = FlutterSoundRecorder();
      await _audioRecorder!.openRecorder();
    }
  }

  Future<void> loadCurrentUserId() async {
    try {
      final currentUser = await _messageRepository.getCurrentUser();
      _currentUserId = currentUser['id'] as String?;
      _username = currentUser['username'] as String? ?? '';
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading current user: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> loadMessages() async {
    _isLoading = true;
    notifyListeners();

    

    try {
      _messages = await _messageRepository.getMessages(conversationId);
    } catch (e) {
      debugPrint('Error loading messages: $e');
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
      _scrollToBottom();
    }
  }

  Future<void> sendMessage({
    String? messageType,
    List<MessageAttachment>? attachments,
  }) async {
    final content = messageController.text.trim();

    // Phải có content hoặc attachments
    if (content.isEmpty && (attachments == null || attachments.isEmpty)) return;

    try {
      // Clear input ngay
      messageController.clear();

      Message sentMessage;
      if (type == 'direct') {
        sentMessage = await _messageRepository.sendMessage(
          conversationId: conversationId,
          recipientId: recipientId ?? '',
          content: content,
          username: username,
          type: messageType,
          attachments: attachments,
        );
      } else {
        sentMessage = await _messageRepository.sendGroupMessage(
          conversationId: conversationId,
          senderId: currentUserId ?? '',
          content: content,
          username: username,
          type: messageType,
          attachments: attachments,
        );
      }

      // KHÔNG append ở đây — socket 'new_message' sẽ nhận và append cho cả
      // người gửi lẫn người nhận, tránh duplicate hoàn toàn.
      // Nếu socket không đến (offline/lỗi), fallback append từ API response.
      final socketWillDeliver = _socketService.isConnected;
      if (!socketWillDeliver) {
        final exists = _messages.any((m) => m.id == sentMessage.id);
        if (!exists) {
          _messages = [..._messages, sentMessage];
          notifyListeners();
          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  // Thêm hoặc xóa reaction
  Future<void> toggleReaction(String messageId, String emoji) async {
    try {
      final updatedReactions = await _reactionRepository.addReaction(
        messageId: messageId,
        emoji: emoji,
      );

      // Cập nhật reactions trong message local
      final messageIndex = _messages.indexWhere((m) => m.id == messageId);
      if (messageIndex != -1) {
        _messages[messageIndex] = Message(
          id: _messages[messageIndex].id,
          conversationId: _messages[messageIndex].conversationId,
          senderId: _messages[messageIndex].senderId,
          username: _messages[messageIndex].username,
          type: _messages[messageIndex].type,
          content: _messages[messageIndex].content,
          attachments: _messages[messageIndex].attachments,
          reactions: updatedReactions,
          createdAt: _messages[messageIndex].createdAt,
          updatedAt: _messages[messageIndex].updatedAt,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling reaction: $e');
      // TODO: Show error to user
    }
  }

  // Chọn và gửi ảnh
  Future<void> pickAndSendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        _isLoading = true;
        notifyListeners();

        // Upload ảnh
        final attachment = await _fileUploadHelper.uploadFile(
          file: File(image.path),
          type: 'image',
        );
        debugPrint('Uploaded image: $attachment');

        // Gửi tin nhắn với ảnh
        await sendMessage(messageType: 'image', attachments: [attachment]);
      }
    } catch (e) {
      debugPrint('Error picking/sending image: $e');
      _showError('Không thể gửi ảnh');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Chọn nhiều ảnh
  Future<void> pickAndSendMultipleImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        _isLoading = true;
        notifyListeners();

        // Upload tất cả ảnh
        final files = images.map((img) => File(img.path)).toList();
        final attachments = await _fileUploadHelper.uploadMultipleFiles(
          files: files,
          type: 'image',
        );

        // Gửi tin nhắn với nhiều ảnh
        if (attachments.isNotEmpty) {
          await sendMessage(messageType: 'image', attachments: attachments);
        }
      }
    } catch (e) {
      debugPrint('Error picking/sending multiple images: $e');
      _showError('Không thể gửi ảnh');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Chụp ảnh và gửi
  Future<void> takePhotoAndSend() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        _isLoading = true;
        notifyListeners();

        // Upload ảnh
        final attachment = await _fileUploadHelper.uploadFile(
          file: File(photo.path),
          type: 'image',
        );

        // Gửi tin nhắn
        await sendMessage(messageType: 'image', attachments: [attachment]);
      }
    } catch (e) {
      debugPrint('Error taking/sending photo: $e');
      _showError('Không thể chụp ảnh');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Bắt đầu ghi âm
  Future<void> startRecording() async {
    if (kIsWeb || _audioRecorder == null) {
      _showError('Ghi âm không hỗ trợ trên web');
      return;
    }

    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        _showError('Cần quyền truy cập microphone');
        return;
      }

      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _audioRecorder!.startRecorder(toFile: path, codec: Codec.aacADTS);

      _isRecording = true;
      _recordingPath = path;
      notifyListeners();
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _showError('Không thể ghi âm');
    }
  }

  // Dừng ghi âm và gửi
  Future<void> stopRecordingAndSend() async {
    if (kIsWeb || _audioRecorder == null) {
      _showError('Ghi âm không hỗ trợ trên web');
      return;
    }

    try {
      final path = await _audioRecorder!.stopRecorder();
      _isRecording = false;
      notifyListeners();

      if (path != null) {
        _isLoading = true;
        notifyListeners();

        // Upload audio
        final attachment = await _fileUploadHelper.uploadFile(
          file: File(path),
          type: 'audio',
        );

        // Gửi tin nhắn
        await sendMessage(messageType: 'audio', attachments: [attachment]);
      }
    } catch (e) {
      debugPrint('Error stopping/sending recording: $e');
      _showError('Không thể gửi tin nhắn thoại');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Hủy ghi âm
  Future<void> cancelRecording() async {
    if (kIsWeb || _audioRecorder == null) return;

    try {
      await _audioRecorder!.stopRecorder();
      _isRecording = false;

      // Xóa file đã ghi
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    }
  }

  // Hiển thị bottom sheet chọn ảnh
  void showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  pickAndSendImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Chọn nhiều ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  pickAndSendMultipleImages();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh'),
                onTap: () {
                  Navigator.pop(context);
                  takePhotoAndSend();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void scrollToBottom() {
    if (!scrollController.hasClients) return;

    scrollController.jumpTo(scrollController.position.maxScrollExtent);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _socketService.leaveConversation(conversationId);
    _socketService.offNewMessageForConversation(conversationId);
    messageController.dispose();
    scrollController.dispose();
    if (!kIsWeb && _audioRecorder != null) {
      _audioRecorder!.closeRecorder();
    }
    super.dispose();
  }
}
