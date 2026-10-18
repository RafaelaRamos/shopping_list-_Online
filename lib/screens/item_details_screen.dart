import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/shopping_item.dart';


class ItemDetailsScreen extends StatefulWidget {
  const ItemDetailsScreen({super.key, required this.itemId});

  static const String routeName = '/details';

  // Id do documento do item no Firestore.
  final String itemId;

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Busca uma unica vez o documento do item pelo id.
  late final Future<DocumentSnapshot> _itemFuture = _firestore
      .collection('itens')
      .doc(widget.itemId)
      .get();

  Future<void> _confirmAndDelete(ShoppingItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir item'),
        content: Text('Deseja mesmo excluir "${item.name}" da lista?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    // Cancelar (ou fechar o dialogo por fora) mantem o item intacto.
    if (confirmed != true) return;

    // Apaga o documento do item no Firestore.
    await _firestore.collection('itens').doc(item.id).delete();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do item')),
      body: FutureBuilder<DocumentSnapshot>(
        future: _itemFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final doc = snapshot.data;
          if (doc == null || !doc.exists) {
            return const Center(child: Text('Item nao encontrado.'));
          }
          final item = ShoppingItem.fromDocumentSnapshot(doc);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DetailRow(label: 'Nome', value: item.name),
              _DetailRow(label: 'Quantidade', value: '${item.quantity}'),
              _DetailRow(
                label: 'Preco unitario',
                value: 'R\$ ${item.unitPrice.toStringAsFixed(2)}',
              ),
              _DetailRow(
                label: 'Subtotal',
                value: 'R\$ ${item.subtotal.toStringAsFixed(2)}',
              ),
              _DetailRow(
                label: 'Situacao',
                value: item.purchased ? 'Comprado' : 'A comprar',
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _confirmAndDelete(item),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                icon: const Icon(Icons.delete),
                label: const Text('Excluir item'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
