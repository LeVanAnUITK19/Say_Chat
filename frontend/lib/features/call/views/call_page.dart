import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../core/services/call_service.dart';

class CallPage extends StatefulWidget {
  final String remoteUserId;
  final String remoteUserName;
  final bool isVideo;
  final bool isCaller;
  final Map<String, dynamic>? incomingOffer;

  const CallPage({
    super.key,
    required this.remoteUserId,
    required this.remoteUserName,
    required this.isVideo,
    required this.isCaller,
    this.incomingOffer,
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  final CallService _callService = CallService();

  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    _callService.onLocalStream = (stream) {
      if (mounted) setState(() => _localRenderer.srcObject = stream);
    };

    _callService.onRemoteStream = (stream) {
      if (mounted) {
        setState(() {
          _remoteRenderer.srcObject = stream;
          _isConnected = true;
        });
      }
    };

    _callService.onCallEnded = () {
      if (mounted) Navigator.pop(context);
    };

    if (widget.isCaller) {
      await _callService.startCall(widget.remoteUserId, widget.isVideo);
    } else {
      await _callService.acceptCall(
        widget.remoteUserId,
        widget.incomingOffer!,
        widget.isVideo,
      );
    }
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _toggleMute() {
    final tracks = _callService.localStream?.getAudioTracks() ?? [];
    for (final t in tracks) {
      t.enabled = _isMuted;
    }
    setState(() => _isMuted = !_isMuted);
  }

  void _toggleCamera() {
    if (!widget.isVideo) return;
    final tracks = _callService.localStream?.getVideoTracks() ?? [];
    for (final t in tracks) {
      t.enabled = _isCameraOff;
    }
    setState(() => _isCameraOff = !_isCameraOff);
  }

  void _endCall() {
    _callService.endCall();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video (full screen) hoặc avatar nếu audio call
            widget.isVideo
                ? RTCVideoView(_remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 64,
                          backgroundColor: Colors.white24,
                          child: Text(
                            widget.remoteUserName.isNotEmpty
                                ? widget.remoteUserName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 52, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.remoteUserName,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isConnected ? 'Đang kết nối...' : 'Đang gọi...',
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),

            // Local video (góc nhỏ) - chỉ hiện khi video call
            if (widget.isVideo)
              Positioned(
                top: 16,
                right: 16,
                width: 100,
                height: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RTCVideoView(_localRenderer, mirror: true),
                ),
              ),

            // Tên người dùng ở trên
            Positioned(
              top: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.remoteUserName,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black)]),
                  ),
                  Text(
                    _isConnected ? 'Đang kết nối...' : 'Đang gọi...',
                    style: const TextStyle(color: Colors.white70,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black)]),
                  ),
                ],
              ),
            ),

            // Control buttons ở dưới
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute
                  _ControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'Bật mic' : 'Tắt mic',
                    onTap: _toggleMute,
                  ),

                  // End call
                  _ControlButton(
                    icon: Icons.call_end,
                    label: 'Kết thúc',
                    color: Colors.red,
                    size: 64,
                    onTap: _endCall,
                  ),

                  // Camera toggle (chỉ hiện khi video)
                  if (widget.isVideo)
                    _ControlButton(
                      icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                      label: _isCameraOff ? 'Bật cam' : 'Tắt cam',
                      onTap: _toggleCamera,
                    )
                  else
                    const SizedBox(width: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white24,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: size / 2,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: size * 0.5),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
