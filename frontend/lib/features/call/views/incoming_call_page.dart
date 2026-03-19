import 'package:flutter/material.dart';
import '../../../core/services/call_service.dart';
import 'call_page.dart';

class IncomingCallPage extends StatelessWidget {
  final String callerId;
  final String callerName;
  final String callType; // 'audio' | 'video'
  final Map<String, dynamic> offer;

  const IncomingCallPage({
    super.key,
    required this.callerId,
    required this.callerName,
    required this.callType,
    required this.offer,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = callType == 'video';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 60),

            // Caller info
            Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white24,
                  child: Text(
                    callerName.isNotEmpty ? callerName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 48, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isVideo ? 'Cuộc gọi video đến...' : 'Cuộc gọi thoại đến...',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reject
                  _CallButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    label: 'Từ chối',
                    onTap: () {
                      CallService().rejectCall(callerId);
                      Navigator.pop(context);
                    },
                  ),

                  // Accept
                  _CallButton(
                    icon: isVideo ? Icons.videocam : Icons.call,
                    color: Colors.green,
                    label: 'Chấp nhận',
                    onTap: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CallPage(
                            remoteUserId: callerId,
                            remoteUserName: callerName,
                            isVideo: isVideo,
                            isCaller: false,
                            incomingOffer: offer,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _CallButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 36,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
