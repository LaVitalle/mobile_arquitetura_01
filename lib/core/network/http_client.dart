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
      }
      throw Failure('Erro na requisição: ${response.statusCode}');
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Falha na conexão: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Failure('Erro no POST: ${response.statusCode}');
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Falha na conexão: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Failure('Erro no PUT: ${response.statusCode}');
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Falha na conexão: $e');
    }
  }

  Future<void> delete(String url) async {
    try {
      final response = await _client.delete(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Failure('Erro no DELETE: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw Failure('Falha na conexão: $e');
    }
  }
}
