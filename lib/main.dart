import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'core/network/http_client.dart';
import 'data/datasources/product_local_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'presentation/pages/product_page.dart';
import 'presentation/viewmodels/product_viewmodel.dart';

void main() {
  final client = AppHttpClient(http.Client());
  final remoteDatasource = ProductRemoteDatasource(client);
  final localDatasource = ProductLocalDatasource();
  final repository = ProductRepositoryImpl(remoteDatasource, localDatasource);
  final viewModel = ProductViewModel(repository);

  runApp(MyApp(viewModel: viewModel));
}

class MyApp extends StatelessWidget {
  final ProductViewModel viewModel;

  const MyApp({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: ProductPage(viewModel: viewModel),
    );
  }
}
