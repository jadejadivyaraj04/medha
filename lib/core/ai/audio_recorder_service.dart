// lib/core/ai/audio_recorder_service.dart

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'audio_converter.dart';
import 'gemma_config.dart';

/// Captures short voice clips for on-device Gemma audio input.
class AudioRecorderService extends GetxService {
  final AudioRecorder _recorder = AudioRecorder();

  final isRecording = false.obs;
  final recordingDuration = Duration.zero.obs;

  Timer? _timer;
  String? _activePath;

  @override
  void onClose() {
    _timer?.cancel();
    _recorder.dispose();
    super.onClose();
  }

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<void> startRecording() async {
    if (isRecording.value) {
      return;
    }

    if (!await hasPermission()) {
      throw StateError('microphone_permission_denied');
    }

    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/medha_doubt_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: AudioConverter.targetSampleRate,
        numChannels: 1,
        bitRate: 256000,
      ),
      path: path,
    );

    _activePath = path;
    recordingDuration.value = Duration.zero;
    isRecording.value = true;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      recordingDuration.value += const Duration(seconds: 1);
      if (recordingDuration.value >= GemmaConfig.maxRecordingDuration) {
        stopRecording();
      }
    });
  }

  Future<Uint8List?> stopRecording() async {
    _timer?.cancel();
    _timer = null;

    if (!isRecording.value) {
      return null;
    }

    isRecording.value = false;
    final path = await _recorder.stop();
    final resolvedPath = path ?? _activePath;
    _activePath = null;

    if (resolvedPath == null || resolvedPath.isEmpty) {
      return null;
    }

    final file = File(resolvedPath);
    if (!await file.exists()) {
      return null;
    }

    final bytes = await file.readAsBytes();
    await file.delete();
    return bytes;
  }

  Future<void> cancelRecording() async {
    _timer?.cancel();
    _timer = null;
    if (isRecording.value) {
      final path = await _recorder.stop();
      isRecording.value = false;
      final resolvedPath = path ?? _activePath;
      _activePath = null;
      if (resolvedPath != null && resolvedPath.isNotEmpty) {
        final file = File(resolvedPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }

  String get formattedDuration =>
      AudioConverter.formatDuration(recordingDuration.value);
}
