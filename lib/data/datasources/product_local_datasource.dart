import '../models/product_model.dart';

class ProductLocalDatasource {
  List<ProductModel>? _cache;

  List<ProductModel>? getProducts() => _cache;

  void saveProducts(List<ProductModel> products) {
    _cache = List.from(products);
  }

  void addProduct(ProductModel product) {
    _cache = [...(_cache ?? []), product];
  }

  void updateProduct(ProductModel product) {
    if (_cache == null) return;
    final index = _cache!.indexWhere((p) => p.id == product.id);
    if (index != -1) _cache![index] = product;
  }

  void removeProduct(int id) {
    _cache?.removeWhere((p) => p.id == id);
  }
}
