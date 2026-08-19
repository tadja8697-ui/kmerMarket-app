import 'package:flutter/material.dart';
import '../models/product.dart';
import 'add_product_screen.dart';

class MyListingsScreen extends StatelessWidget {
  final String currentUserId;
  final List<Product> allProducts;
  final void Function(Product) onProductUpdated;
  final void Function(Product) onProductDeleted;

  const MyListingsScreen({
    super.key,
    required this.currentUserId,
    required this.allProducts,
    required this.onProductUpdated,
    required this.onProductDeleted,
  });

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'annonce ?'),
        content: Text('Voulez-vous vraiment supprimer "${product.name_p}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              onProductDeleted(product);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Annonce supprimée')),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editProduct(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductScreen(
          currentUserId: currentUserId,
          productToEdit: product,
          onSave: onProductUpdated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myProducts = allProducts.where((p) => p.userid == currentUserId).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes annonces')),
      body: myProducts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storefront_outlined, size: 56, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text(
                      'Vous n\'avez encore publié aucun produit',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: myProducts.length,
              itemBuilder: (context, index) {
                final product = myProducts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.image,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                        ),
                      ),
                    ),
                    title: Text(product.name_p, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${product.price.toStringAsFixed(0)} FCFA'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _editProduct(context, product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          onPressed: () => _confirmDelete(context, product),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
