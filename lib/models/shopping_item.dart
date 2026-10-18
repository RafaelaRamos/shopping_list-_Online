import 'package:cloud_firestore/cloud_firestore.dart';

// Item da lista de compras, guardado na colecao 'itens' do Firestore.
class ShoppingItem {
  // O id agora e o id (String) do documento no Firestore.
  late String id;
  late String name;
  late int quantity;
  late double unitPrice;
  late bool purchased;

  // Monta o item a partir de um documento lido do Firestore.
  ShoppingItem.fromDocumentSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    name = doc['nome'];
    quantity = doc['quantidade'];
    // Um preco como 25 pode voltar do Firestore como int, por isso o num.
    unitPrice = (doc['precoUnitario'] as num).toDouble();
    purchased = doc['comprado'];
  }

  // Forma alternativa, usando lista de inicializadores (`:`). Nesse caso os
  // campos podem ser `final` em vez de `late`:
  //
  // ShoppingItem.fromDocumentSnapshot(DocumentSnapshot doc)
  //   : id = doc.id,
  //     name = doc['nome'],
  //     quantity = doc['quantidade'],
  //     unitPrice = (doc['precoUnitario'] as num).toDouble(),
  //     purchased = doc['comprado'];

  double get subtotal => quantity * unitPrice;
}
