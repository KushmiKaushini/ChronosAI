// Author: K K K Ekanayake
// Task: TASK-008 — Audio Service
// ============================================================================
// ChronosAI Audio Service
// Handles voice recording (PCM 16-bit mono 16kHz) for Gemini Live API,
// silence detection (VAD), amplitude monitoring, and audio playback.
// ============================================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../config/app_constants.dart';

/// Audio configuration constants for Gemini Live API compatibility.
class AudioConfig {
  /// Sample rate in Hz — 16kHz is optimal for Gemini speech recognition.
  static const int sampleRate = 16000;

  /// Number of audio channels — 1 for mono recording.
  static const int channels = 1;

  /// Audio encoding format — PCM 16-bit (LINEAR16).
  static const AudioEncoder encoder = AudioEncoder.pcm16bits;

  /// Maximum recording duration in seconds (5 minutes safety cutoff).
  static const int maxRecordingSeconds = 300;

  /// Silence threshold in dBFS — audio below this level is considered silence.
  static const double silenceThresholdDb = -40.0;

  /// Duration of continuous silence before auto-stopping (seconds).
  static const double silenceAutoStopSeconds = 2.5;

  /// Amplitude monitoring interval in milliseconds.
  static const int amplitudeMonitorIntervalMs = 50;
}

/// AudioService manages the full voice recording and playback pipeline.
///
/// Implements Voice Activity Detection (VAD) via amplitude monitoring,
/// PCM 16-bit mono recording at 16kHz for Gemini Live API compatibility,
/// and a playback interface ready for AI-generated audio responses.
class AudioService extends ChangeNotifier {
  AudioService() {
    _recorder = AudioRecorder();
  }

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  late final AudioRecorder _recorder;

  // ---------------------------------------------------------------------------
  // Public state fields
  // ---------------------------------------------------------------------------

  /// Current voice state (idle, listening, thinking, speaking).
  VoiceState currentState = VoiceState.idle;

  /// Whether the microphone is currently recording.
  bool isRecording = false;

  /// Normalized amplitude level (0.0 to 1.0) for UI visualizations.
  double amplitude = 0.0;

  // ---------------------------------------------------------------------------
  // Private fields for VAD and recording management
  // ---------------------------------------------------------------------------

  /// Path to the current recording file.
  String? _currentRecordingPath;

  /// Timer for amplitude monitoring during recording.
  Timer? _amplitudeTimer;

  /// Timer for max recording duration safety cutoff.
  Timer? _maxDurationTimer;

  /// Duration of continuous silence detected so far (seconds).
  double _silenceDuration = 0.0;

  /// Whether the service has been disposed.
  bool _isDisposed = false;

  // ---------------------------------------------------------------------------
  // Permission handling
  // ---------------------------------------------------------------------------

  /// Requests microphone permission from the user.
  ///
  /// Returns `true` if permission is granted, `false` otherwise.
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('AudioService: Failed to request microphone permission — $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Recording pipeline
  // ---------------------------------------------------------------------------

  /// Starts audio recording with Gemini Live API-compatible settings.
  ///
  /// Configures the recorder for PCM 16-bit mono at 16kHz, saves to a temp
  /// file, and begins amplitude monitoring for VAD silence detection.
  ///
  /// Returns `true` if recording started successfully, `false` otherwise.
  Future<bool> startRecording() async {
    if (_isDisposed) {
      debugPrint('AudioService: Cannot start recording — service disposed');
      return false;
    }

    if (isRecording) {
      debugPrint('AudioService: Already recording, ignoring startRecording()');
      return true;
    }

    try {
      // Ensure microphone permission is granted.
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) {
        debugPrint('AudioService: Microphone permission denied');
        return false;
      }

      // Generate temp file path for the recording.
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${tempDir.path}/chronosai_recording_$timestamp.pcm';

      // Configure and start the recorder.
      const recordConfig = RecordConfig(
        encoder: AudioConfig.encoder,
        sampleRate: AudioConfig.sampleRate,
        numChannels: AudioConfig.channels,
      );

      await _recorder.start(recordConfig, path: _currentRecordingPath!);

      // Update state.
      isRecording = true;
      currentState = VoiceState.listening;
      _silenceDuration = 0.0;
      amplitude = 0.0;
      notifyListeners();

      // Start amplitude monitoring for VAD.
      _startAmplitudeMonitoring();

      // Start max duration safety cutoff.
      _maxDurationTimer = Timer(
        const Duration(seconds: AudioConfig.maxRecordingSeconds),
        () {
          debugPrint('AudioService: Max recording duration reached, auto-stopping');
          stopRecording();
        },
      );

      debugPrint('AudioService: Recording started — $_currentRecordingPath');
      return true;
    } catch (e) {
      debugPrint('AudioService: Failed to start recording — $e');
      isRecording = false;
      currentState = VoiceState.idle;
      _currentRecordingPath = null;
      notifyListeners();
      return false;
    }
  }

  /// Stops the current recording and returns the audio file path.
  ///
  /// Sets state to [VoiceState.thinking] to indicate the AI is processing.
  /// Returns the path to the recorded PCM file, or `null` if no recording
  /// was in progress or an error occurred.
  Future<String?> stopRecording() async {
    if (!isRecording) {
      debugPrint('AudioService: Not recording, ignoring stopRecording()');
      return null;
    }

    try {
      // Stop the recorder.
      final path = await _recorder.stop();

      // Cancel timers.
      _amplitudeTimer?.cancel();
      _amplitudeTimer = null;
      _maxDurationTimer?.cancel();
      _maxDurationTimer = null;

      // Update state.
      isRecording = false;
      currentState = VoiceState.thinking;
      amplitude = 0.0;
      notifyListeners();

      final resultPath = path ?? _currentRecordingPath;
      debugPrint('AudioService: Recording stopped — $resultPath');

      // Reset for next recording.
      _currentRecordingPath = null;
      _silenceDuration = 0.0;

      return resultPath;
    } catch (e) {
      debugPrint('AudioService: Failed to stop recording — $e');
      isRecording = false;
      currentState = VoiceState.idle;
      amplitude = 0.0;
      _currentRecordingPath = null;
      _silenceDuration = 0.0;
      notifyListeners();
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Audio playback (stub — implementation depends on Gemini response format)
  // ---------------------------------------------------------------------------

  /// Plays back audio data from Gemini's response.
  ///
  /// Accepts either raw PCM audio bytes or a file path. The actual playback
  /// implementation is a stub — the audio format returned by Gemini Live
  /// needs to be confirmed before full implementation.
  ///
  /// Sets [VoiceState.speaking] during playback and [VoiceState.idle] when done.
  Future<void> playResponseAudio({
    Uint8List? audioData,
    String? filePath,
  }) async {
    if (_isDisposed) {
      debugPrint('AudioService: Cannot play audio — service disposed');
      return;
    }

    if (audioData == null && filePath == null) {
      debugPrint('AudioService: No audio data or file path provided');
      return;
    }

    try {
      currentState = VoiceState.speaking;
      notifyListeners();

      // TODO: Implement actual audio playback once Gemini response format is known.
      // The Gemini Live API may return PCM 16-bit audio, which can be played
      // using the `just_audio` package or `AudioPlayer` from `record`.
      //
      // For now, this is a stub that simulates playback duration.
      // Replace with actual player implementation:
      //
      //   final player = AudioPlayer();
      //   if (filePath != null) {
      //     await player.setFilePath(filePath);
      //   } else if (audioData != null) {
      //     await player.setAudioSource(ByteAudioSource(audioData));
      //   }
      //   await player.play();
      //   player.playerStateStream.listen((state) {
      //     if (state.processingState == ProcessingState.completed) {
      //       _onPlaybackComplete();
      //     }
      //   });

      // Stub: simulate playback with a short delay.
      await Future.delayed(const Duration(milliseconds: 100));

      _onPlaybackComplete();
    } catch (e) {
      debugPrint('AudioService: Failed to play response audio — $e');
      currentState = VoiceState.idle;
      notifyListeners();
    }
  }

  /// Called when playback completes naturally.
  void _onPlaybackComplete() {
    if (_isDisposed) return;
    currentState = VoiceState.idle;
    notifyListeners();
    debugPrint('AudioService: Playback complete');
  }

  // ---------------------------------------------------------------------------
  // Amplitude monitoring & Voice Activity Detection (VAD)
  // ---------------------------------------------------------------------------

  /// Starts monitoring the microphone amplitude for VAD visualization
  /// and silence detection.
  ///
  /// Runs a periodic timer that reads the current amplitude from the recorder.
  /// If amplitude stays below the silence threshold for the configured
  /// duration, recording is automatically stopped.
  void _startAmplitudeMonitoring() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(
      const Duration(milliseconds: AudioConfig.amplitudeMonitorIntervalMs),
      (_) => _monitorAmplitude(),
    );
  }

  /// Monitors audio amplitude and handles silence-based auto-stop.
  ///
  /// Reads the current amplitude from the recorder, normalizes it to 0.0–1.0,
  /// and tracks silence duration for VAD auto-stop functionality.
  Future<void> _monitorAmplitude() async {
    if (!isRecording || _isDisposed) return;

    try {
      final currentAmplitude = await _recorder.getAmplitude();

      // Amplitude.current returns dBFS (typically -160.0 to 0.0 silence→loud).
      final double dbLevel = currentAmplitude.current;

      // Normalize amplitude: map from [-160, 0] to [0.0, 1.0].
      final normalizedAmplitude = ((dbLevel + 160.0) / 160.0).clamp(0.0, 1.0);
      amplitude = normalizedAmplitude;

      // VAD: check if amplitude is below silence threshold.
      if (dbLevel < AudioConfig.silenceThresholdDb) {
        _silenceDuration += AudioConfig.amplitudeMonitorIntervalMs / 1000.0;

        if (_silenceDuration >= AudioConfig.silenceAutoStopSeconds) {
          debugPrint(
            'AudioService: Silence detected for ${_silenceDuration.toStringAsFixed(1)}s '
            '(threshold: ${AudioConfig.silenceThresholdDb}dBFS), auto-stopping',
          );
          // Auto-stop on sustained silence.
          unawaited(stopRecording());
          return;
        }
      } else {
        // Reset silence counter when audio is above threshold.
        _silenceDuration = 0.0;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('AudioService: Amplitude monitoring error — $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  /// Disposes of all resources used by the AudioService.
  ///
  /// Stops any active recording, cancels timers, and releases the recorder.
  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    try {
      _amplitudeTimer?.cancel();
      _amplitudeTimer = null;
      _maxDurationTimer?.cancel();
      _maxDurationTimer = null;

      if (isRecording) {
        unawaited(_recorder.stop());
        isRecording = false;
      }

      _recorder.dispose();
      debugPrint('AudioService: Disposed');
    } catch (e) {
      debugPrint('AudioService: Error during dispose — $e');
    }

    super.dispose();
  }
}
