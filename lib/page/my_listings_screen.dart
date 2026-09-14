import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../service/api_services.dart';
import 'add_product_screen.dart';

class MyListingsScreen extends StatefulWidget {
  final String currentUserId;
  final List<Product> allProducts;
  final FutureOr<void> Function(Product) onProductUpdated;
  final FutureOr<void> Function(Product) onProductDeleted;

  const MyListingsScreen({
    super.key,
    required this.currentUserId,
    required this.allProducts,
    required this.onProductUpdated,
    required this.onProductDeleted,
  });

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  late List<Product> _myProducts;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _myProducts = widget.allProducts.where((p) => p.userid == widget.currentUserId).toList();
    _fetchMyProducts();
  }

  Future<void> _fetchMyProducts() async {
    setState(() => _isLoading = true);
    try {
      final userProducts = await ApiService.getProductsByUserId(widget.currentUserId);
      if (mounted && userProducts.isNotEmpty) {
        setState(() {
          _myProducts = userProducts;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('[MyListingsScreen] Erreur getProductsByUserId: $e');
    }
    if (mounted) {
      setState(() {
        _myProducts = widget.allProducts.where((p) => p.userid == widget.currentUserId).toList();
        _isLoading = false;
      });
    }
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'annonce ?'),
        content: Text('Voulez-vous vraiment supprimer "${product.name_p}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await widget.onProductDeleted(product);
                if (!mounted) return;
                setState(() {
                  _myProducts.removeWhere((p) => p.id == product.id);
                });
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Annonce supprimée avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de la suppression: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
          currentUserId: widget.currentUserId,
          productToEdit: product,
          onSave: (updated) async {
            await widget.onProductUpdated(updated);
            if (!mounted) return;
            setState(() {
              final index = _myProducts.indexWhere((p) => p.id == updated.id);
              if (index != -1) {
                _myProducts[index] = updated;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildProductThumbnail(String image) {
    if (image.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
      );
    }
    if (image.startsWith('http://') || image.startsWith('https://') || image.startsWith('blob:')) {
      return Image.network(
        image,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 56,
          height: 56,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
        ),
      );
    }
    if (!kIsWeb) {
      try {
        final file = File(image);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 56,
              height: 56,
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
            ),
          );
        }
      } catch (_) {}
    }
    return Container(
      width: 56,
      height: 56,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes annonces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchMyProducts,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMyProducts,
        child: _isLoading && _myProducts.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _myProducts.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
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
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: _myProducts.length,
                    itemBuilder: (context, index) {
                      final product = _myProducts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildProductThumbnail(product.image),
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
      ),
    );
  }
}
