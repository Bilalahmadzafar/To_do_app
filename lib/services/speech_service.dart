// lib/services/speech_service.dart
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Wrapper around speech_to_text v7.x API.
/// Exposes initialize(), startListening(), stopListening(), cancel(), dispose().
class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool isListening = false;
  String voiceInput = '';

  /// Initialize plugin and return whether speech recognition is available.
  Future<bool> initialize() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          // optional: handle status updates if you want
        },
        onError: (error) {
          // optional: handle errors if you want
        },
      );
      return available;
    } catch (_) {
      return false;
    }
  }

  /// Start listening. onResult is called with partial/final recognized text.
  Future<void> startListening(void Function(String) onResult) async {
    // Ensure plugin is initialized (initialize() is idempotent)
    final available = await initialize();
    if (!available) return;

    voiceInput = '';
    isListening = true;

    await _speech.listen(
      onResult: (result) {
        voiceInput = result.recognizedWords;
        onResult(voiceInput);
      },
      // Use SpeechListenOptions instead of deprecated params
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
        // pauseFor, onDevice, etc. can be set here if needed
      ),
    );
  }

  /// Stop listening gracefully.
  Future<void> stopListening() async {
    if (!isListening) return;
    await _speech.stop();
    isListening = false;
  }

  /// Cancel listening immediately.
  Future<void> cancel() async {
    await _speech.cancel();
    isListening = false;
  }

  /// Dispose if you want to free resources (not strictly required).
  Future<void> dispose() async {
    await _speech.cancel();
    isListening = false;
  }
}
