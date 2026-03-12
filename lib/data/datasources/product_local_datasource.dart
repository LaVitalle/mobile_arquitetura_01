import '../models/product_model.dart';

class ProductLocalDatasource {
  List<ProductModel>? _cache;

  List<ProductModel>? getProducts() {
    return _cache;
  }

  void saveProducts(List<ProductModel> products) {
    _cache = List.from(products);
  }
}
