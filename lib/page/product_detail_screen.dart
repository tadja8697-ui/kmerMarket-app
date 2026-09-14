import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String sellerPhone;
  final String sellerName;
  final String quartier;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.sellerPhone = '699000000',
    this.sellerName = 'Vendeur',
    this.quartier = 'Quartier non précisé',
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;

  String get effectiveSellerName =>
      (widget.product.sellerName != null && widget.product.sellerName!.isNotEmpty)
          ? widget.product.sellerName!
          : widget.sellerName;

  String get effectiveSellerPhone =>
      (widget.product.sellerPhone != null && widget.product.sellerPhone!.isNotEmpty)
          ? widget.product.sellerPhone!
          : widget.sellerPhone;

  Future<void> _contactSeller() async {
    final phone = effectiveSellerPhone.replaceAll(RegExp(r'\D'), '');
    final cleanPhone = phone.startsWith('237') ? phone : '237$phone';

    final message = Uri.encodeComponent(
      'Bonjour, je suis intéressé(e) par "${widget.product.name_p}" sur KmerMarket.',
    );
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$message');

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp')),
      );
    }
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Ajouté aux favoris' : 'Retiré des favoris'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildHeaderImage() {
    final image = widget.product.image.trim();
    if (image.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
      );
    }
    if (image.startsWith('http://') || image.startsWith('https://') || image.startsWith('blob:')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
        ),
      );
    }
    if (!kIsWeb) {
      try {
        final file = File(image);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
            ),
          );
        }
      } catch (_) {}
    }
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final sellerName = effectiveSellerName;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            actions: [
              IconButton(
                icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                color: _isFavorite ? Colors.red : null,
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderImage(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name_p,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.price.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Catégorie
                  if (product.category.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Chip(
                        label: Text(product.category),
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(widget.quartier, style: TextStyle(color: Colors.grey.shade700)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(product.desc, style: TextStyle(color: Colors.grey.shade800, height: 1.4)),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Bloc vendeur
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                        child: Text(
                          sellerName.isNotEmpty ? sellerName[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sellerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Row(
                              children: [
                                Icon(Icons.verified, size: 14, color: Colors.green.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  'Vendeur certifié',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _contactSeller,
            icon: const Icon(Icons.chat),
            label: const Text('Contacter le vendeur (WhatsApp)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
