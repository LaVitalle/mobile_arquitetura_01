import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failure.dart';
import '../../domain/entities/product.dart';
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

  Future<void> addProduct(Product product) async {
    final current = state;
    if (current is! ProductSuccess) {
      await loadProducts();
      return addProduct(product);
    }
    try {
      final saved = await repository.addProduct(product);
      final withId = saved.id != null ? saved : saved.copyWith(id: _nextLocalId(current.products));
      state = ProductSuccess([withId, ...current.products]);
    } on Failure catch (e) {
      state = ProductError(e.message);
    } catch (e) {
      state = ProductError('Erro ao adicionar: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    final current = state;
    if (current is! ProductSuccess) return;
    try {
      final saved = await repository.updateProduct(product);
      final list = current.products
          .map((p) => p.id == product.id ? saved.copyWith(
                title: product.title,
                price: product.price,
                description: product.description,
                category: product.category,
                image: product.image,
              ) : p)
          .toList();
      state = ProductSuccess(list);
    } on Failure catch (e) {
      state = ProductError(e.message);
    } catch (e) {
      state = ProductError('Erro ao atualizar: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    final current = state;
    if (current is! ProductSuccess) return;
    try {
      await repository.deleteProduct(id);
      final list = current.products.where((p) => p.id != id).toList();
      state = ProductSuccess(list);
    } on Failure catch (e) {
      state = ProductError(e.message);
    } catch (e) {
      state = ProductError('Erro ao excluir: $e');
    }
  }

  int _nextLocalId(List<Product> products) {
    if (products.isEmpty) return 1;
    final maxId = products
        .map((p) => p.id ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }
}
