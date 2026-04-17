import '../../core/network/http_client.dart';
import '../models/product_model.dart';

class ProductRemoteDatasource {
  static const String _baseUrl = 'https://fakestoreapi.com/products';

  final AppHttpClient client;

  ProductRemoteDatasource(this.client);

  Future<List<ProductModel>> getProducts() async {
    final data = await client.getList(_baseUrl);
    return data
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    final json = await client.post(_baseUrl, product.toJson());
    return ProductModel.fromJson(json);
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    final json = await client.put('$_baseUrl/${product.id}', product.toJson());
    return ProductModel.fromJson(json);
  }

  Future<void> deleteProduct(int id) async {
    await client.delete('$_baseUrl/$id');
  }
}
