import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/network/http_client.dart';
import '../../data/datasources/product_local_datasource.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../notifiers/favorites_notifier.dart';
import '../notifiers/product_notifier.dart';
import '../state/product_state.dart';

// Core
final httpClientProvider = Provider<AppHttpClient>((ref) {
  return AppHttpClient(http.Client());
});

// Data
final remoteDatasourceProvider = Provider<ProductRemoteDatasource>((ref) {
  return ProductRemoteDatasource(ref.read(httpClientProvider));
});

final localDatasourceProvider = Provider<ProductLocalDatasource>((ref) {
  return ProductLocalDatasource();
});

// Domain
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    ref.read(remoteDatasourceProvider),
    ref.read(localDatasourceProvider),
  );
});

// Presentation - Estado dos produtos (loading, success, error)
final productStateProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier(ref.read(productRepositoryProvider));
});

// Presentation - Estado dos favoritos (Set de IDs)
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<int>>((ref) {
  return FavoritesNotifier();
});

// Presentation - Filtro de favoritos
final showFavoritesOnlyProvider = StateProvider<bool>((ref) => false);

// Computed - Contador de favoritos
final favoritesCountProvider = Provider<int>((ref) {
  return ref.watch(favoritesProvider).length;
});
