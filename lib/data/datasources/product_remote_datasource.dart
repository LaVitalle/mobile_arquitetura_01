import '../../core/network/http_client.dart';
import '../models/product_model.dart';

class ProductRemoteDatasource {
  final AppHttpClient client;

  ProductRemoteDatasource(this.client);

  Future<List<ProductModel>> getProducts() async {
    final List<dynamic> data = await client.getList(
      "https://fakestoreapi.com/products",
    );

    return data
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }
}
