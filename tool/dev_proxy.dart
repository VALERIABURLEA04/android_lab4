import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

const _upstream = 'https://test-api-jlbn.onrender.com/lab2026/v1/';

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8081);
  final client = http.Client();
  stdout.writeln('GemStore API proxy: http://127.0.0.1:8081/lab2026/v1/');

  await for (final request in server) {
    unawaited(_handle(request, client));
  }
  client.close();
}

Future<void> _handle(HttpRequest request, http.Client client) async {
  final response = request.response;
  final origin = request.headers.value('origin');
  if (origin != null) {
    final uri = Uri.tryParse(origin);
    if (uri == null ||
        !{'localhost', '127.0.0.1'}.contains(uri.host) ||
        !{'http', 'https'}.contains(uri.scheme)) {
      response.statusCode = HttpStatus.forbidden;
      await response.close();
      return;
    }
    response.headers.set(HttpHeaders.accessControlAllowOriginHeader, origin);
    response.headers.set(HttpHeaders.varyHeader, 'Origin');
  }

  response.headers.set(
    HttpHeaders.accessControlAllowMethodsHeader,
    'GET, OPTIONS',
  );
  response.headers.set(HttpHeaders.accessControlAllowHeadersHeader, 'Accept');
  if (request.method == 'OPTIONS') {
    response.statusCode = HttpStatus.noContent;
    await response.close();
    return;
  }

  const routes = {
    '/lab2026/v1/feed': 'feed',
    '/lab2026/v1/feed/details': 'feed/details',
  };
  final path = routes[request.uri.path];
  if (request.method != 'GET' || path == null || request.uri.hasQuery) {
    response.statusCode = HttpStatus.notFound;
    await response.close();
    return;
  }

  try {
    final upstream = await client
        .get(
          Uri.parse('$_upstream$path'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 60));
    response.statusCode = upstream.statusCode;
    response.headers.contentType = ContentType.json;
    response.add(upstream.bodyBytes);
  } on Object catch (error) {
    response.statusCode = HttpStatus.badGateway;
    response.headers.contentType = ContentType.json;
    response.write('{"error":"The upstream API is unavailable."}');
    stderr.writeln(error);
  } finally {
    await response.close();
  }
}
