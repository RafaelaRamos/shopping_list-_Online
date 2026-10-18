import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/item_details_screen.dart';
import 'screens/new_item_screen.dart';
import 'screens/shopping_list_screen.dart';

Future<void> main() async {
  // Garante que o Flutter esteja pronto antes de inicializar o Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  // No Android, as configuracoes vem do android/app/google-services.json.
  await Firebase.initializeApp();
  runApp(const ShoppingListApp());
}

class ShoppingListApp extends StatelessWidget {
  const ShoppingListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de compras',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {'/': (context) => const ShoppingListScreen()},
    
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case NewItemScreen.routeName:
            return MaterialPageRoute<bool>(
              settings: settings,
              builder: (context) => const NewItemScreen(),
            );
          case ItemDetailsScreen.routeName:
            // O id agora e o id (String) do documento no Firestore.
            final itemId = settings.arguments as String;
            return MaterialPageRoute<bool>(
              settings: settings,
              builder: (context) => ItemDetailsScreen(itemId: itemId),
            );
          default:
            return null;
        }
      },
    );
  }
}
