import '../../core/errors/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remoteDatasource;
  final ProductLocalDatasource localDatasource;

  ProductRepositoryImpl(this.remoteDatasource, this.localDatasource);

  @override
  Future<List<Product>> getProducts() async {
    try {
      final models = await remoteDatasource.getProducts();
      localDatasource.saveProducts(models);
      return _toEntityList(models);
    } catch (e) {
      final cached = localDatasource.getProducts();
      if (cached != null && cached.isNotEmpty) {
        return _toEntityList(cached);
      }
      throw Failure('Não foi possível carregar os produtos e não há cache disponível.');
    }
  }

  List<Product> _toEntityList(List<ProductModel> models) {
    return models
        .map((m) => Product(
              id: m.id,
              title: m.title,
              price: m.price,
              image: m.image,
            ))
        .toList();
  }
}
