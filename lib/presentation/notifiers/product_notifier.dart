import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failure.dart';
import '../../domain/repositories/product_repository.dart';
import '../state/product_state.dart';

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductRepository repository;

  ProductNotifier(this.repository) : super(ProductInitial());

  Future<void> loadProducts() async {
    state = ProductLoading();
    try {
      final result = await repository.getProducts();
      state = ProductSuccess(result);
    } on Failure catch (e) {
      state = ProductError(e.message);
    } catch (e) {
      state = ProductError('Erro inesperado: $e');
    }
  }
}
