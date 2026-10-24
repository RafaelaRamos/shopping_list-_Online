import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItem {
  
  late String id;
  late String name;
  late int quantity;
  late double unitPrice;
  late bool purchased;


  ShoppingItem.fromDocumentSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    name = doc['nome'];
    quantity = doc['quantidade'];
    
    unitPrice = (doc['precoUnitario'] as num).toDouble();
    purchased = doc['comprado'];
  }

 

  double get subtotal => quantity * unitPrice;
}
