// Stub for web platform
class FlutterSoundRecorder {
  Future<void> openRecorder() async {}
  Future<void> startRecorder({String? toFile, dynamic codec}) async {}
  Future<String?> stopRecorder() async => null;
  Future<void> closeRecorder() async {}
}

class Codec {
  static const aacADTS = null;
}
