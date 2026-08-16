import 'package:flutter/material.dart';
import '../models/users.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Utilisateur en dur en attendant la connexion réelle (auth backend)
  static final Users _hardcodedUser = Users(
    id: 1,
    name: 'Ada Raoulyne',
    email: 'ada.raoulyne@example.com',
    phone: '652085604',
    password: '', // jamais affiché
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              child: Text(
                _hardcodedUser.name.isNotEmpty ? _hardcodedUser.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _hardcodedUser.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 28),

          _ProfileInfoTile(icon: Icons.email_outlined, label: 'Email', value: _hardcodedUser.email),
          _ProfileInfoTile(icon: Icons.phone_outlined, label: 'Téléphone', value: _hardcodedUser.phone),

          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: déconnexion réelle
            },
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}
