import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/users.dart';
import 'home_screen.dart';
import 'add_product_screen.dart';
import 'profile_screen.dart';

/// Page racine qui gère la navigation entre Home / AddProduct / Profil,
/// et porte l'état partagé entre ces pages (liste de produits, favoris,
/// utilisateur courant) en attendant la connexion au vrai backend.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Utilisateur connecté en dur (viendra de la session réelle après login)
  final Users currentUser = Users(
    id: 1,
    name: 'Ada Épesse',
    email: 'ada.epesse@example.com',
    phone: '699123456',
    password: '',
  );

  // Produits en dur en attendant la BDD
  late List<Product> products = [
    Product(
      id: 1,
      name_p: 'Machine à coudre',
      desc: 'Machine à coudre en bon état, peu utilisée',
      price: 45000,
      image: 'https://images.unsplash.com/photo-1590959651373-a3db0f38a961?w=400',
      userid: '1',
      category: 'Maison',
    ),
    Product(
      id: 2,
      name_p: 'Vélo enfant',
      desc: 'Vélo pour enfant 6-9 ans',
      price: 15000,
      image: 'https://images.unsplash.com/photo-1571333250630-f0230c320b6d?w=400',
      userid: '2',
      category: 'Transport',
    ),
    Product(
      id: 3,
      name_p: 'Table basse',
      desc: 'Table basse en bois massif',
      price: 20000,
      image: 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=400',
      userid: '1',
      category: 'Maison',
    ),
    Product(
      id: 4,
      name_p: 'Perceuse',
      desc: 'Perceuse électrique avec accessoires',
      price: 12000,
      image: 'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=400',
      userid: '3',
      category: 'Outils',
    ),
  ];

  final Set<int> favoriteIds = {};

  void _toggleFavorite(Product product) {
    setState(() {
      if (favoriteIds.contains(product.id)) {
        favoriteIds.remove(product.id);
      } else {
        favoriteIds.add(product.id);
      }
    });
  }

  void _addProduct(Product product) {
    setState(() => products = [product, ...products]);
  }

  void _updateProduct(Product updated) {
    setState(() {
      products = products.map((p) => p.id == updated.id ? updated : p).toList();
    });
  }

  void _deleteProduct(Product product) {
    setState(() {
      products = products.where((p) => p.id != product.id).toList();
      favoriteIds.remove(product.id);
    });
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        products: products,
        favoriteIds: favoriteIds,
        onFavoriteToggle: _toggleFavorite,
      ),
      AddProductScreen(
        currentUserId: currentUser.id.toString(),
        onSave: _addProduct,
      ),
      ProfileScreen(
        user: currentUser,
        products: products,
        favoriteIds: favoriteIds,
        onProductUpdated: _updateProduct,
        onProductDeleted: _deleteProduct,
      ),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Publier',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
