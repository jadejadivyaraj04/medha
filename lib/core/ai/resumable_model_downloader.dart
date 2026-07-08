// lib/core/ai/resumable_model_downloader.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Downloads the on-device model with HTTP Range resume.
///
/// The file streams into `<app-support>/models/<name>.part`; if the download
/// is interrupted (network drop, app kill, cancel), the partial file is kept
/// and the next call resumes from its byte offset instead of starting over.
/// Redirects are followed manually so the auth token is only ever sent to the
/// original host, never to the signed CDN URL it redirects to.
class ResumableModelDownloader {
  ResumableModelDownloader({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  CancelToken? _cancelToken;

  static const _maxRedirects = 5;

  /// Returns the path of the fully downloaded model file.
  Future<String> download({
    required String url,
    String? authToken,
    required void Function(double progress) onProgress,
  }) async {
    final dir = await getApplicationSupportDirectory();
    final fileName = Uri.parse(url).pathSegments.last;
    final finalFile = File('${dir.path}/models/$fileName');
    final partFile = File('${finalFile.path}.part');

    if (await finalFile.exists()) {
      onProgress(1.0);
      return finalFile.path;
    }
    await finalFile.parent.create(recursive: true);

    var offset = await partFile.exists() ? await partFile.length() : 0;
    _cancelToken = CancelToken();

    final response = await _openStream(url, authToken, offset);
    final status = response.statusCode ?? 0;

    int total;
    if (status == 206) {
      // Content-Range: bytes <start>-<end>/<total>
      final range = response.headers.value('content-range') ?? '';
      total = int.tryParse(range.split('/').last) ?? 0;
      debugPrint('ResumableModelDownloader: resuming at $offset of $total');
    } else {
      // Server ignored the Range header — restart from zero.
      offset = 0;
      total = int.tryParse(
            response.headers.value(Headers.contentLengthHeader) ?? '',
          ) ??
          0;
    }

    final raf = await partFile.open(
      mode: status == 206 ? FileMode.append : FileMode.write,
    );
    var received = offset;
    try {
      await for (final chunk in response.data!.stream) {
        raf.writeFromSync(chunk);
        received += chunk.length;
        if (total > 0) {
          onProgress((received / total).clamp(0.0, 1.0));
        }
      }
    } finally {
      await raf.close();
    }

    if (total > 0 && received != total) {
      // Stream ended early; keep the .part file so the next call resumes.
      throw const HttpException('Model download ended before completion.');
    }

    await partFile.rename(finalFile.path);
    onProgress(1.0);
    return finalFile.path;
  }

  Future<Response<ResponseBody>> _openStream(
    String url,
    String? authToken,
    int offset,
  ) async {
    var current = url;
    var sendAuth = true;
    final originalHost = Uri.parse(url).host;

    for (var hop = 0; hop < _maxRedirects; hop++) {
      final response = await _dio.get<ResponseBody>(
        current,
        options: Options(
          responseType: ResponseType.stream,
          followRedirects: false,
          headers: {
            if (sendAuth && authToken != null && authToken.isNotEmpty)
              'Authorization': 'Bearer $authToken',
            if (offset > 0) 'Range': 'bytes=$offset-',
          },
          validateStatus: (code) => code != null && code < 400,
        ),
        cancelToken: _cancelToken,
      );

      final code = response.statusCode ?? 0;
      if (code == 301 || code == 302 || code == 303 || code == 307 || code == 308) {
        final location = response.headers.value('location');
        if (location == null) {
          throw const HttpException('Redirect without a Location header.');
        }
        current = Uri.parse(current).resolve(location).toString();
        // Signed CDN URLs reject extra auth; only the original host gets it.
        sendAuth = Uri.parse(current).host == originalHost;
        continue;
      }
      return response;
    }
    throw const HttpException('Too many redirects while fetching the model.');
  }

  void cancel() {
    _cancelToken?.cancel('User cancelled model download');
  }
}
