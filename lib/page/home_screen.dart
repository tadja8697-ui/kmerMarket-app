import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Données en dur en attendant la connexion à la BDD (comme demandé)
  static final List<Product> _hardcodedProducts = [
    Product(
      id: 1,
      name_p: 'Machine à coudre',
      desc: 'Machine à coudre en bon état, peu utilisée',
      price: 45000,
      image: 'https://images.unsplash.com/photo-1590959651373-a3db0f38a961?w=400',
      userid: '1',
    ),
    Product(
      id: 2,
      name_p: 'Vélo enfant',
      desc: 'Vélo pour enfant 6-9 ans',
      price: 15000,
      image: 'https://images.unsplash.com/photo-1571333250630-f0230c320b6d?w=400',
      userid: '2',
    ),
    Product(
      id: 3,
      name_p: 'Table basse',
      desc: 'Table basse en bois massif',
      price: 20000,
      image: 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=400',
      userid: '1',
    ),
    Product(
      id: 4,
      name_p: 'Perceuse',
      desc: 'Perceuse électrique avec accessoires',
      price: 12000,
      image: 'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=400',
      userid: '3',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KmerMarket'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: _hardcodedProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final product = _hardcodedProducts[index];
            return ProductCard(
              product: product,
              onTap: () {
                // TODO: navigation vers le détail du produit
              },
            );
          },
        ),
      ),
    );
  }
}
