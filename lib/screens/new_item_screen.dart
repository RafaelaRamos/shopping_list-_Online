import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  static const String routeName = '/new';

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o nome do item.';
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    final quantity = int.tryParse((value ?? '').trim());
    if (quantity == null) {
      return 'Informe a quantidade como um numero inteiro.';
    }
    if (quantity <= 0) {
      return 'A quantidade deve ser maior que zero.';
    }
    return null;
  }

  String? _validateUnitPrice(String? value) {
    // Aceita virgula como separador decimal, comum no teclado brasileiro.
    final price = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    if (price == null) {
      return 'Informe o preco como um numero.';
    }
    if (price < 0) {
      return 'O preco nao pode ser negativo.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    await _firestore.collection('itens').add({
      'nome': _nameController.text.trim(),
      'quantidade': int.parse(_quantityController.text.trim()),
      'precoUnitario': double.parse(
        _unitPriceController.text.trim().replaceAll(',', '.'),
      ),
      'comprado': false,
      'criadoEm': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: _validateName,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: _validateQuantity,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _unitPriceController,
              decoration: const InputDecoration(
                labelText: 'Preco unitario',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validateUnitPrice,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
