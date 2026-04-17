import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_text_field.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? initialProduct;

  const ProductFormScreen({super.key, this.initialProduct});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _service = ProductService();

  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _imageController;

  bool _saving = false;

  bool get _isEditing => widget.initialProduct != null;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProduct;
    _titleController = TextEditingController(text: p?.title ?? '');
    _priceController =
        TextEditingController(text: p != null ? p.price.toString() : '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _categoryController = TextEditingController(text: p?.category ?? '');
    _imageController = TextEditingController(text: p?.image ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final product = Product(
      id: widget.initialProduct?.id,
      title: _titleController.text.trim(),
      price: double.parse(_priceController.text.replaceAll(',', '.')),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      image: _imageController.text.trim(),
    );

    try {
      final saved = _isEditing
          ? await _service.updateProduct(product)
          : await _service.addProduct(product);

      if (!mounted) return;
      Navigator.of(context).pop(saved.copyWith(
        title: product.title,
        price: product.price,
        description: product.description,
        category: product.category,
        image: product.image,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar produto' : 'Novo produto'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                ProductTextField(
                  controller: _titleController,
                  label: 'Nome',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                ),
                ProductTextField(
                  controller: _priceController,
                  label: 'Preço',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe o preço';
                    }
                    final parsed =
                        double.tryParse(v.replaceAll(',', '.'));
                    if (parsed == null || parsed < 0) {
                      return 'Preço inválido';
                    }
                    return null;
                  },
                ),
                ProductTextField(
                  controller: _categoryController,
                  label: 'Categoria',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe a categoria'
                      : null,
                ),
                ProductTextField(
                  controller: _imageController,
                  label: 'URL da imagem',
                ),
                ProductTextField(
                  controller: _descriptionController,
                  label: 'Descrição',
                  maxLines: 4,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe a descrição'
                      : null,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _saving ? null : _submit,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isEditing ? 'Salvar' : 'Cadastrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
