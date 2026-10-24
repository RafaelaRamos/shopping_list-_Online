import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/shopping_item.dart';
import 'item_details_screen.dart';
import 'new_item_screen.dart';


class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   void _openNewItem() {
    Navigator.of(context).pushNamed(NewItemScreen.routeName);
  }

  void _openDetails(ShoppingItem item) {
    Navigator.of(
      context,
    ).pushNamed(ItemDetailsScreen.routeName, arguments: item.id);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de compras')),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('itens').orderBy('criadoEm').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Nao foi possivel carregar a lista: ${snapshot.error}'),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

        
          final items = snapshot.data!.docs
              .map((doc) => ShoppingItem.fromDocumentSnapshot(doc))
              .toList();
          return Column(
            children: [
              Expanded(
                child: items.isEmpty
                    ? const _EmptyListMessage()
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _ItemTile(
                            item: item,
                            onTap: () => _openDetails(item),
                           
                          );
                        },
                      ),
              ),
              _TotalBar(items: items),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewItem,
        tooltip: 'Adicionar item',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.onTap,
    
  });

  final ShoppingItem item;
  final VoidCallback onTap;
 

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey)
      ),
      child: ListTile(
        onTap: onTap,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
      
          children: [
            Row(
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.w600,

                  fontSize: 14
                  ),
                ),
              ],
            ),
               Row(
                 children: [
                   Text(
                               'Quantidade: ${item.quantity} ',    style: TextStyle(
                
                  fontSize: 12
                  ),
                             ),
                 ],
               ),
            Row(
              children: [
                Text(
                  'Preco unitario: R\$ ${item.unitPrice.toStringAsFixed(2)}',  style: TextStyle(
                
                  fontSize: 12
                  ),
                  ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
         
          ],
        ),
        
        trailing: Text('Total: R\$ ${item.subtotal.toStringAsFixed(2)}'),
      ),
    );
  }
}

class _EmptyListMessage extends StatelessWidget {
  const _EmptyListMessage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Sua lista esta vazia.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalBar extends StatelessWidget {
  const _TotalBar({required this.items});

  final List<ShoppingItem> items;

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(0, (sum, item) => sum + item.subtotal);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                'R\$ ${total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
