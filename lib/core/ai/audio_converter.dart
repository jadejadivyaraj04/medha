// lib/core/ai/audio_converter.dart

import 'dart:typed_data';

/// Gemma 3n expects PCM 16 kHz, 16-bit, mono (or WAV with that format).
class AudioConverter {
  AudioConverter._();

  static const int targetSampleRate = 16000;
  static const int bytesPerSample = 2;

  static Uint8List toPCM16kHzMono(
    Uint8List pcmData, {
    required int sourceSampleRate,
    int sourceChannels = 1,
  }) {
    if (sourceSampleRate == targetSampleRate && sourceChannels == 1) {
      return pcmData;
    }

    final samples = _bytesToSamples(pcmData);
    final monoSamples =
        sourceChannels == 2 ? _stereoToMono(samples) : samples;
    final resampledSamples = sourceSampleRate != targetSampleRate
        ? _resample(monoSamples, sourceSampleRate, targetSampleRate)
        : monoSamples;

    return _samplesToBytes(resampledSamples);
  }

  static ({Uint8List pcmData, int sampleRate, int channels}) parseWav(
    Uint8List wavData,
  ) {
    if (wavData.length < 44) {
      throw ArgumentError('Invalid WAV data: too short');
    }

    final byteData = ByteData.sublistView(wavData);
    final riff = String.fromCharCodes(wavData.sublist(0, 4));
    if (riff != 'RIFF') {
      throw ArgumentError('Invalid WAV: missing RIFF header');
    }

    final wave = String.fromCharCodes(wavData.sublist(8, 12));
    if (wave != 'WAVE') {
      throw ArgumentError('Invalid WAV: missing WAVE format');
    }

    var offset = 12;
    var sampleRate = 0;
    var channels = 0;
    Uint8List? pcmData;

    while (offset < wavData.length - 8) {
      final chunkId = String.fromCharCodes(wavData.sublist(offset, offset + 4));
      final chunkSize = byteData.getUint32(offset + 4, Endian.little);
      final chunkDataStart = offset + 8;

      if (chunkId == 'fmt ') {
        channels = byteData.getUint16(chunkDataStart + 2, Endian.little);
        sampleRate = byteData.getUint32(chunkDataStart + 4, Endian.little);
      } else if (chunkId == 'data') {
        pcmData = Uint8List.fromList(
          wavData.sublist(chunkDataStart, chunkDataStart + chunkSize),
        );
      }

      offset = chunkDataStart + chunkSize;
      if (chunkSize % 2 != 0) {
        offset++;
      }
    }

    if (pcmData == null) {
      throw ArgumentError('Invalid WAV: data chunk not found');
    }
    if (sampleRate == 0 || channels == 0) {
      throw ArgumentError('Invalid WAV: fmt chunk not found or invalid');
    }

    return (pcmData: pcmData, sampleRate: sampleRate, channels: channels);
  }

  static Uint8List prepareForGemma(Uint8List audioBytes) {
    if (audioBytes.length >= 4 &&
        String.fromCharCodes(audioBytes.sublist(0, 4)) == 'RIFF') {
      final parsed = parseWav(audioBytes);
      return toPCM16kHzMono(
        parsed.pcmData,
        sourceSampleRate: parsed.sampleRate,
        sourceChannels: parsed.channels,
      );
    }

    return audioBytes;
  }

  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static Int16List _bytesToSamples(Uint8List bytes) {
    final byteData = ByteData.sublistView(bytes);
    final samples = Int16List(bytes.length ~/ 2);
    for (var i = 0; i < samples.length; i++) {
      samples[i] = byteData.getInt16(i * 2, Endian.little);
    }
    return samples;
  }

  static Uint8List _samplesToBytes(Int16List samples) {
    final bytes = Uint8List(samples.length * 2);
    final byteData = ByteData.sublistView(bytes);
    for (var i = 0; i < samples.length; i++) {
      byteData.setInt16(i * 2, samples[i], Endian.little);
    }
    return bytes;
  }

  static Int16List _stereoToMono(Int16List stereoSamples) {
    final monoSamples = Int16List(stereoSamples.length ~/ 2);
    for (var i = 0; i < monoSamples.length; i++) {
      final left = stereoSamples[i * 2];
      final right = stereoSamples[i * 2 + 1];
      monoSamples[i] = ((left + right) ~/ 2).toInt();
    }
    return monoSamples;
  }

  static Int16List _resample(
    Int16List samples,
    int sourceSampleRate,
    int targetRate,
  ) {
    final ratio = sourceSampleRate / targetRate;
    final newLength = (samples.length / ratio).round();
    final resampled = Int16List(newLength);

    for (var i = 0; i < newLength; i++) {
      final srcIndex = (i * ratio).floor();
      final srcIndexNext = (srcIndex + 1).clamp(0, samples.length - 1);
      final fraction = (i * ratio) - srcIndex;
      final value = samples[srcIndex] * (1 - fraction) +
          samples[srcIndexNext] * fraction;
      resampled[i] = value.round().clamp(-32768, 32767);
    }

    return resampled;
  }
}
