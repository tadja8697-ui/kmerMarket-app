import 'package:flutter/material.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un produit'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TODO (Patrice) : formulaire
            // - sélection d'image (image_picker)
            // - nom du produit
            // - description
            // - prix
            // - bouton "Publier"
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  'Formulaire à venir',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
