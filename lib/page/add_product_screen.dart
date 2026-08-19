import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';

class AddProductScreen extends StatefulWidget {
  final String currentUserId;
  final void Function(Product) onSave;
  final Product? productToEdit; // si non-null, la page passe en mode édition

  const AddProductScreen({
    super.key,
    required this.currentUserId,
    required this.onSave,
    this.productToEdit,
  });

  bool get isEditing => productToEdit != null;

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;

  File? _newlyPickedImage;
  String? _existingImageUrl; 
  bool _isLoading = false;
  late String _selectedCategory;
  final List<String> _categories = ['Maison', 'Outils', 'Transport', 'Autre'];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final existing = widget.productToEdit;
    _nameController = TextEditingController(text: existing?.name_p ?? '');
    _descController = TextEditingController(text: existing?.desc ?? '');
    _priceController = TextEditingController(text: existing != null ? existing.price.toStringAsFixed(0) : '');
    _selectedCategory = existing?.category ?? 'Maison';
    _existingImageUrl = existing?.image;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _newlyPickedImage = File(pickedFile.path);
        _existingImageUrl = null;
      });
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir depuis la galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le nom du produit est requis';
    if (value.trim().length < 3) return 'Le nom est trop court';
    return null;
  }

  String? _validateDesc(String? value) {
    if (value == null || value.trim().isEmpty) return 'La description est requise';
    if (value.trim().length < 10) return 'Décrivez un peu plus le produit (10 caractères min)';
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le prix est requis';
    final price = double.tryParse(value.trim());
    if (price == null) return 'Entrez un nombre valide';
    if (price <= 0) return 'Le prix doit être supérieur à 0';
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final imagePath = _newlyPickedImage?.path ?? _existingImageUrl;
    if (imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins une photo du produit')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // a faire
      //a faire
      await Future.delayed(const Duration(seconds: 1));

      final product = Product(
        id: widget.productToEdit?.id ?? DateTime.now().millisecondsSinceEpoch,
        name_p: _nameController.text.trim(),
        desc: _descController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        image: imagePath,
        userid: widget.currentUserId,
        category: _selectedCategory,
      );

      widget.onSave(product);

      if (mounted) {
        if (widget.isEditing) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Annonce mise à jour')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produit publié !')),
          );
          _formKey.currentState!.reset();
          _nameController.clear();
          _descController.clear();
          _priceController.clear();
          setState(() {
            _newlyPickedImage = null;
            _existingImageUrl = null;
            _selectedCategory = 'Maison';
          });
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _newlyPickedImage != null || _existingImageUrl != null;

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Modifier le produit' : 'Ajouter un produit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Sélecteur d'image ---
              GestureDetector(
                onTap: _showImageSourceSheet,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasImage
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            _newlyPickedImage != null
                                ? Image.file(_newlyPickedImage!, fit: BoxFit.cover)
                                : Image.network(
                                    _existingImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                                    ),
                                  ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                radius: 16,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.close, size: 18, color: Colors.white),
                                  onPressed: () => setState(() {
                                    _newlyPickedImage = null;
                                    _existingImageUrl = null;
                                  }),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 36, color: Colors.grey.shade500),
                            const SizedBox(height: 8),
                            Text(
                              'Ajouter une photo du produit',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _validateName,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit',
                  prefixIcon: Icon(Icons.label_outline),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _descController,
                maxLines: 4,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _validateDesc,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _validatePrice,
                decoration: const InputDecoration(
                  labelText: 'Prix (FCFA)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleSubmit,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check),
                label: Text(_isLoading
                    ? 'Enregistrement...'
                    : (widget.isEditing ? 'Enregistrer les modifications' : 'Publier le produit')),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
