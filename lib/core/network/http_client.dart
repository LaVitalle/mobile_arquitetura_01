import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/failure.dart';

class AppHttpClient {
  final http.Client _client;

  AppHttpClient(this._client);

  Future<List<dynamic>> getList(String url) async {
    try {
      final response = await _client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Failure('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Falha na conexão: $e');
    }
  }
}
