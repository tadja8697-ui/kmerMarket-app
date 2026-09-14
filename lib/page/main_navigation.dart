import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/users.dart';
import '../service/api_services.dart';
import 'home_screen.dart';
import 'add_product_screen.dart';
import 'profile_screen.dart';

/// Page racine qui gère la navigation entre Home / AddProduct / Profil,
/// et synchronise l'état avec l'API Spring Boot (port 8004).
class MainNavigation extends StatefulWidget {
  final Users? currentUser;

  const MainNavigation({super.key, this.currentUser});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late Users currentUser;
  List<Product> products = [];
  bool _isLoading = false;
  String? _errorMessage;

  final Set<int> favoriteIds = {};

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser ??
        Users(
          id: 1,
          name: 'Utilisateur KmerMarket',
          email: 'contact@kmermarket.cm',
          phone: '699123456',
          password: '',
        );
    _loadProducts();
  }

  /// Charge tous les produits depuis l'API (GET /api/getAllProducts)
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetched = await ApiService.getAllProducts();
      if (mounted) {
        setState(() {
          products = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[MainNavigation] Erreur chargement produits: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Impossible de contacter le serveur (port 8004).';
        });
      }
    }
  }

  void _toggleFavorite(Product product) {
    setState(() {
      if (favoriteIds.contains(product.id)) {
        favoriteIds.remove(product.id);
      } else {
        favoriteIds.add(product.id);
      }
    });
  }

  /// Ajoute un produit via l'API (POST /api/add)
  Future<void> _addProduct(Product product) async {
    final saved = await ApiService.addProduct(product);
    setState(() {
      products = [saved, ...products];
    });
  }

  /// Met à jour un produit via l'API (PUT /api/update/{id})
  Future<void> _updateProduct(Product updated) async {
    final saved = await ApiService.updateProduct(updated.id, updated);
    setState(() {
      products = products.map((p) => p.id == saved.id ? saved : p).toList();
    });
  }

  /// Supprime un produit via l'API (DELETE /api/delete/{id})
  Future<void> _deleteProduct(Product product) async {
    await ApiService.deleteProduct(product.id);
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
        onRefresh: _loadProducts,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
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
        onRefreshProducts: _loadProducts,
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
