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
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      final cached = localDatasource.getProducts();
      if (cached != null && cached.isNotEmpty) {
        return cached.map((m) => m.toEntity()).toList();
      }
      throw Failure(
        'Não foi possível carregar os produtos e não há cache disponível.',
      );
    }
  }

  @override
  Future<Product> addProduct(Product product) async {
    final model = ProductModel.fromEntity(product);
    final saved = await remoteDatasource.addProduct(model);
    final toStore = saved.id != null ? saved : model;
    localDatasource.addProduct(toStore);
    return toStore.toEntity();
  }

  @override
  Future<Product> updateProduct(Product product) async {
    if (product.id == null) {
      throw Failure('Produto sem id não pode ser atualizado.');
    }
    final model = ProductModel.fromEntity(product);
    final saved = await remoteDatasource.updateProduct(model);
    final toStore = saved.id != null ? saved : model;
    localDatasource.updateProduct(toStore);
    return toStore.toEntity();
  }

  @override
  Future<void> deleteProduct(int id) async {
    await remoteDatasource.deleteProduct(id);
    localDatasource.removeProduct(id);
  }
}
