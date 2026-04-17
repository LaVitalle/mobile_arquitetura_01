import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductService {
  static const String _baseUrl = 'https://fakestoreapi.com/products';

  final http.Client _client;

  ProductService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Product>> fetchProducts() async {
    final response = await _client.get(Uri.parse(_baseUrl));

    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar produtos (${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Product> fetchProduct(int id) async {
    final response = await _client.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar produto (${response.statusCode})');
    }

    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Product> addProduct(Product product) async {
    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Falha ao cadastrar produto (${response.statusCode})');
    }

    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Product> updateProduct(Product product) async {
    if (product.id == null) {
      throw Exception('Produto sem id não pode ser atualizado');
    }

    final response = await _client.put(
      Uri.parse('$_baseUrl/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar produto (${response.statusCode})');
    }

    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteProduct(int id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Falha ao excluir produto (${response.statusCode})');
    }
  }
}
