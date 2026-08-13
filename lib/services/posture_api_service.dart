import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../core/network/api_client.dart';

class PostureApiService {
  static const String _baseUrl = 'https://mga-posture-corrector-service-production.up.railway.app';
  static final ApiClient _client = ApiClient(baseUrl: _baseUrl);

  static Future<Map<String, dynamic>> uploadPostureVideo(String videoPath) async {
    final File videoFile = File(videoPath);
    if (!await videoFile.exists()) {
      return {'success': false, 'feedback': 'Target video file does not exist on this device.'};
    }

    final String rawFileName = path.basename(videoPath);
    final String fileName = rawFileName.replaceAll(RegExp(r'[^a-zA-Z0-9.]'), '_');

    try {
      debugPrint('=== [STEP 1: FETCHING PRE-SIGNED URL FROM CLOUD] ===');

      final urlResponse = await _client.get('/api/analyze/request-url', query: {'fileName': fileName});

      debugPrint('► Cloud Server Response Status Code: ${urlResponse.statusCode}');
      debugPrint('► Cloud Server Response Body: ${urlResponse.body}');

      if (urlResponse.statusCode != 200) {
        return {'success': false, 'feedback': 'Cloud gatekeeper refused. Status: ${urlResponse.statusCode}'};
      }

      final Map<String, dynamic> urlData = jsonDecode(urlResponse.body);
      final String uploadUrl = urlData['uploadUrl'] ?? '';
      final String fileKey = urlData['fileKey'] ?? '';

      if (uploadUrl.isEmpty || fileKey.isEmpty) {
        return {'success': false, 'feedback': 'Received empty routing signatures from the cloud gateway.'};
      }

      try {
        final Uri parsedUri = Uri.parse(uploadUrl);
        final String signedHeaders = parsedUri.queryParameters['X-Amz-SignedHeaders'] ?? 'NOTFOUND';
        final String signatureHash = parsedUri.queryParameters['X-Amz-Signature'] ?? 'NOTFOUND';
        final String credentialsScope = parsedUri.queryParameters['X-Amz-Credential'] ?? 'NOTFOUND';

        debugPrint('======================================================');
        debugPrint('🔮 VERIFYING BACKEND GENERATED SIGNATURE METRICS:');
        debugPrint('► Target Storage Host: ${parsedUri.host}');
        debugPrint('► Cryptographic Hash Signature: $signatureHash');
        debugPrint('► Mandatory Signed Headers Expected by Server: $signedHeaders');
        debugPrint('► Full Credential Scope String: $credentialsScope');
        debugPrint('======================================================');
      } catch (e) {
        debugPrint('⚠️ Verification logger failed to parse the URL string: $e');
      }

      debugPrint('=== [STEP 2: STREAMING DIRECT TO STORAGE BUCKET] ===');

      final Uri uploadUri = Uri.parse(uploadUrl);
      final int fileLength = await videoFile.length();

      final HttpClient ioClient = HttpClient();

      try {
        final HttpClientRequest rawRequest = await ioClient.putUrl(uploadUri);

        rawRequest.headers.clear();
        rawRequest.headers.chunkedTransferEncoding = false;
        rawRequest.contentLength = fileLength;
        rawRequest.headers.set('content-type', 'video/mp4');
        rawRequest.headers.set('host', uploadUri.host);

        debugPrint('ℹ️ Handshaking With Strict Outbound Headers Matrix: \n${rawRequest.headers.toString()}');

        final RandomAccessFile openedFile = await videoFile.open(mode: FileMode.read);

        try {
          final int bufferSize = 64 * 1024;
          int bytesRead = 0;
          int chunkCounter = 0;

          debugPrint('🎬 Starting raw byte stream pipeline write operations...');

          while (bytesRead < fileLength) {
            final int remaining = fileLength - bytesRead;
            final int toRead = remaining > bufferSize ? bufferSize : remaining;

            final Uint8List chunk = await openedFile.read(toRead);

            chunkCounter++;
            if (chunkCounter == 1 || chunkCounter % 200 == 0 || bytesRead + toRead >= fileLength) {
              double progressPercent = ((bytesRead + chunk.length) / fileLength) * 100;
              debugPrint('⚙️ Streaming Chunk #$chunkCounter | Sent: ${bytesRead + chunk.length} / $fileLength bytes (${progressPercent.toStringAsFixed(1)}%)');
            }

            rawRequest.add(chunk);
            bytesRead += chunk.length;

            await Future.delayed(Duration.zero);
          }
          debugPrint('🏁 All bytes written down the local socket pool. Closing stream...');
        } finally {
          await openedFile.close();
        }

        debugPrint('⏳ Awaiting Cloud Storage signature validation response...');
        final HttpClientResponse ioResponse = await rawRequest.close();

        debugPrint('► Backblaze B2 Storage Response Status Code: ${ioResponse.statusCode}');

        if (ioResponse.statusCode != 200 && ioResponse.statusCode != 201) {
          final String errorBody = await ioResponse.transform(utf8.decoder).join();
          debugPrint('► Failure Response Body: $errorBody');
          return {'success': false, 'feedback': 'Storage target gateway rejected the file payload upload.'};
        }

        debugPrint('🚀 DIRECT STORAGE UPLOAD SUCCESSFUL!');
      } finally {
        ioClient.close();
      }

      debugPrint('=== [STEP 3: INITIALIZING MOVENET KINEMATICS PIPELINE ON RAILWAY] ===');

      final processingResponse = await _client.post('/api/analyze/squat', body: {'fileKey': fileKey}, auth: false);

      final Map<String, dynamic> analysisData = jsonDecode(processingResponse.body);

      if (processingResponse.statusCode == 200 && analysisData['success'] == true) {
        return {
          'success': true,
          'feedback': analysisData['feedback'] ?? 'Analysis complete.',
          'repsCounted': analysisData['repsCounted'] ?? 0,
          'deepestKneeAngle': analysisData['deepestKneeAngle'] ?? 0,
          'maxForwardLeanAngle': analysisData['maxForwardLeanAngle'] ?? 0,
          'repAnglesBreakdown': analysisData['repAnglesBreakdown'] ?? [],
        };
      } else {
        return {
          'success': false,
          'feedback': analysisData['error'] ?? 'Kinematics analysis failed inside the cloud core.',
        };
      }
    } catch (e) {
      debugPrint('❌ CRITICAL NETWORK ERROR: $e');
      return {'success': false, 'feedback': 'Connection reset or network drop encountered: ${e.toString()}'};
    }
  }
}
