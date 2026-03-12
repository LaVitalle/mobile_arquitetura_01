import 'package:flutter/foundation.dart';
import '../../core/errors/failure.dart';
import '../../domain/repositories/product_repository.dart';
import '../state/product_state.dart';

class ProductViewModel {
  final ProductRepository repository;

  final ValueNotifier<ProductState> state = ValueNotifier(ProductInitial());

  ProductViewModel(this.repository);

  Future<void> loadProducts() async {
    state.value = ProductLoading();
    try {
      final result = await repository.getProducts();
      state.value = ProductSuccess(result);
    } on Failure catch (e) {
      state.value = ProductError(e.message);
    } catch (e) {
      state.value = ProductError('Erro inesperado: $e');
    }
  }
}
