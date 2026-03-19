import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'socket_service.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final SocketService _socketService = SocketService();

  String? _remoteUserId;

  // Expose local stream để CallPage dùng toggle mic/camera
  MediaStream? get localStream => _localStream;

  // Callbacks để UI lắng nghe
  void Function(MediaStream stream)? onLocalStream;
  void Function(MediaStream stream)? onRemoteStream;
  void Function()? onCallEnded;

  static const Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  Future<void> _initPeerConnection() async {
    _peerConnection = await createPeerConnection(_iceServers);

    // Khi có ICE candidate → gửi cho peer
    _peerConnection!.onIceCandidate = (candidate) {
      if (_remoteUserId != null) {
        _socketService.sendIceCandidate(_remoteUserId!, candidate.toMap());
      }
    };

    // Khi nhận được remote stream
    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        onRemoteStream?.call(_remoteStream!);
      }
    };
  }

  Future<MediaStream> _getLocalStream(bool isVideo) async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': isVideo,
    });
    _localStream = stream;
    onLocalStream?.call(stream);
    return stream;
  }

  /// Caller: khởi tạo và gửi offer
  Future<void> startCall(String remoteUserId, bool isVideo) async {
    _remoteUserId = remoteUserId;
    await _initPeerConnection();

    final stream = await _getLocalStream(isVideo);
    stream.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, stream);
    });

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _socketService.sendCallOffer(remoteUserId, offer.toMap(), isVideo ? 'video' : 'audio');

    // Lắng nghe answer từ callee
    _socketService.onCallAnswer((data) async {
      final answer = RTCSessionDescription(data['answer']['sdp'], data['answer']['type']);
      await _peerConnection!.setRemoteDescription(answer);
    });

    // Lắng nghe ICE candidates từ callee
    _socketService.onIceCandidate((data) async {
      final candidate = RTCIceCandidate(
        data['candidate']['candidate'],
        data['candidate']['sdpMid'],
        data['candidate']['sdpMLineIndex'],
      );
      await _peerConnection!.addCandidate(candidate);
    });

    _socketService.onCallEnd(() => _handleRemoteEnd());
    _socketService.onCallRejected(() => _handleRemoteEnd());
  }

  /// Callee: nhận offer và gửi answer
  Future<void> acceptCall(String callerId, Map<String, dynamic> offer, bool isVideo) async {
    _remoteUserId = callerId;
    await _initPeerConnection();

    final stream = await _getLocalStream(isVideo);
    stream.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, stream);
    });

    final remoteDesc = RTCSessionDescription(offer['sdp'], offer['type']);
    await _peerConnection!.setRemoteDescription(remoteDesc);

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    _socketService.sendCallAnswer(callerId, answer.toMap());

    // Lắng nghe ICE candidates từ caller
    _socketService.onIceCandidate((data) async {
      final candidate = RTCIceCandidate(
        data['candidate']['candidate'],
        data['candidate']['sdpMid'],
        data['candidate']['sdpMLineIndex'],
      );
      await _peerConnection!.addCandidate(candidate);
    });

    _socketService.onCallEnd(() => _handleRemoteEnd());
  }

  /// Từ chối call
  void rejectCall(String callerId) {
    _socketService.sendCallRejected(callerId);
    _cleanup();
  }

  /// Kết thúc call
  void endCall() {
    if (_remoteUserId != null) {
      _socketService.sendCallEnd(_remoteUserId!);
    }
    _cleanup();
  }

  void _handleRemoteEnd() {
    onCallEnded?.call();
    _cleanup();
  }

  void _cleanup() {
    _localStream?.getTracks().forEach((t) => t.stop());
    _remoteStream?.getTracks().forEach((t) => t.stop());
    _peerConnection?.close();
    _peerConnection = null;
    _localStream = null;
    _remoteStream = null;
    _remoteUserId = null;
    _socketService.offCallEvents();
    debugPrint('📞 Call cleaned up');
  }
}
