import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class TelemetryClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    final String path = request.url.path;
    final String method = request.method;

    try {
      final http.StreamedResponse response = await _inner.send(request);
      stopwatch.stop();

      developer.log(
        '⚡ [TELEMETRÍA] | $method | Status: ${response.statusCode} | Tiempo: ${stopwatch.elapsedMilliseconds}ms | Path: $path',
        name: 'trueke.network',
      );

      return response;
    } catch (e) {
      stopwatch.stop();

      developer.log(
        '🚨 [TELEMETRÍA ERROR] | $method | Fallo tras ${stopwatch.elapsedMilliseconds}ms | Path: $path | Error: $e',
        name: 'trueke.network',
        error: e,
      );

      rethrow;
    }
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
