import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../providers/providers.dart';
import '../state/product_state.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';
import 'product_form_page.dart';

class ProductPage extends ConsumerStatefulWidget {
  const ProductPage({super.key});

  @override
  ConsumerState<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends ConsumerState<ProductPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productStateProvider.notifier).loadProducts();
    });
  }

  Future<void> _openForm({Product? product}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductFormPage(initialProduct: product),
      ),
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir produto'),
        content: Text('Deseja realmente excluir "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true || product.id == null) return;
    if (!mounted) return;
    await ref.read(productStateProvider.notifier).deleteProduct(product.id!);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productStateProvider);
    final favorites = ref.watch(favoritesProvider);
    final favCount = ref.watch(favoritesCountProvider);
    final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        actions: [
          if (state is ProductSuccess) ...[
            IconButton(
              icon: Icon(
                showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                color: showFavoritesOnly ? Colors.red : null,
              ),
              tooltip:
                  showFavoritesOnly ? 'Mostrar todos' : 'Mostrar favoritos',
              onPressed: () {
                ref.read(showFavoritesOnlyProvider.notifier).state =
                    !showFavoritesOnly;
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Badge(
                  label: Text('$favCount'),
                  child: const Icon(Icons.star),
                ),
              ),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
            onPressed: () =>
                ref.read(productStateProvider.notifier).loadProducts(),
          ),
        ],
      ),
      body: _buildBody(state, favorites, showFavoritesOnly),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Novo'),
      ),
    );
  }

  Widget _buildBody(
    ProductState state,
    Set<int> favorites,
    bool showFavoritesOnly,
  ) {
    if (state is ProductLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProductError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(productStateProvider.notifier).loadProducts(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is ProductSuccess) {
      List<Product> products = state.products;

      if (showFavoritesOnly) {
        products = products.where((p) => favorites.contains(p.id)).toList();
      }

      if (products.isEmpty) {
        return const Center(
          child: Text('Nenhum produto encontrado.'),
        );
      }

      return ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final isFavorite =
              product.id != null && favorites.contains(product.id);

          return ProductCard(
            product: product,
            isFavorite: isFavorite,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: product),
                ),
              );
            },
            onEdit: () => _openForm(product: product),
            onDelete: () => _confirmDelete(product),
            onToggleFavorite: () {
              if (product.id != null) {
                ref
                    .read(favoritesProvider.notifier)
                    .toggleFavorite(product.id!);
              }
            },
          );
        },
      );
    }

    return const Center(
      child: Text('Pressione o botão para carregar os produtos'),
    );
  }
}
