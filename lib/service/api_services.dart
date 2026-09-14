import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/users.dart';

/// Service gérant tous les appels API vers le backend Spring Boot KmerMarket (port 8004)
class ApiService {
  /// Port par défaut du backend Spring Boot
  static const String port = '8004';

  /// URL de base par défaut :
  /// - Web / Windows Desktop : localhost:8004
  /// - Émulateur Android : 10.0.2.2:8004 (alias du localhost de la machine hôte)
  static String baseUrl = _getDefaultBaseUrl();

  static String _getDefaultBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:$port/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:$port/api';
      }
    } catch (_) {
      // Ignore si la plateforme n'est pas supportée
    }
    return 'http://localhost:$port/api';
  }

  /// Permet de modifier l'adresse IP manuellement (utile sur appareil Android physique avec Wi-Fi)
  static void setCustomHost(String host, {String customPort = port}) {
    baseUrl = 'http://$host:$customPort/api';
    debugPrint('[ApiService] Nouvelle URL de base: $baseUrl');
  }

  /// Permet de redéfinir directement l'URL de base complète
  static void setBaseUrl(String url) {
    baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    debugPrint('[ApiService] URL de base mise à jour: $baseUrl');
  }

  /// Headers standards pour les requêtes JSON
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ==========================================
  // AUTHENTIFICATION
  // ==========================================

  /// POST /api/auth/register
  /// Enregistre un nouvel utilisateur
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final payload = {
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'password': password,
    };

    try {
      debugPrint('[ApiService] POST $url');
      final response = await http
          .post(url, headers: _headers, body: jsonEncode(payload))
          .timeout(const Duration(seconds: 12));

      final responseText = utf8.decode(response.bodyBytes);
      debugPrint('[ApiService] Register response (${response.statusCode}): $responseText');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': responseText.isNotEmpty ? responseText : 'Inscription réussie',
        };
      } else {
        return {
          'success': false,
          'message': responseText.isNotEmpty ? responseText : 'Erreur lors de l\'inscription',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Le serveur a mis trop de temps à répondre.',
      };
    } catch (e) {
      debugPrint('[ApiService] Erreur register: $e');
      final err = e.toString().toLowerCase();
      if (err.contains('socket') || err.contains('failed to fetch') || err.contains('clientexception') || err.contains('xmlhttprequest')) {
        return {
          'success': false,
          'message': 'Impossible de contacter le serveur ($baseUrl). Vérifiez que Spring Boot tourne sur le port $port.',
        };
      }
      return {
        'success': false,
        'message': 'Erreur lors de l\'inscription: $e',
      };
    }
  }

  /// POST /api/auth/login
  /// Authentifie l'utilisateur via email et mot de passe
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final payload = {
      'email': email.trim().toLowerCase(),
      'password': password,
    };

    try {
      debugPrint('[ApiService] POST $url');
      final response = await http
          .post(url, headers: _headers, body: jsonEncode(payload))
          .timeout(const Duration(seconds: 12));

      final responseText = utf8.decode(response.bodyBytes);
      debugPrint('[ApiService] Login response (${response.statusCode}): $responseText');

      if (response.statusCode == 200) {
        Users? user;
        try {
          final decoded = jsonDecode(responseText);
          if (decoded is Map<String, dynamic>) {
            user = Users.fromJson(decoded);
          }
        } catch (_) {
          String parsedName = '';
          if (responseText.contains('bienvenue ')) {
            parsedName = responseText.split('bienvenue ').last.trim();
          }
          user = Users(
            id: 1,
            name: parsedName.isNotEmpty ? parsedName : email.split('@').first,
            email: email.trim(),
            phone: '',
            password: '',
          );
        }

        return {
          'success': true,
          'message': responseText,
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': responseText.isNotEmpty ? responseText : 'Email ou mot de passe incorrect',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Délai d\'attente dépassé. Le serveur ne répond pas.',
      };
    } catch (e) {
      debugPrint('[ApiService] Erreur login: $e');
      final err = e.toString().toLowerCase();
      if (err.contains('socket') || err.contains('failed to fetch') || err.contains('clientexception') || err.contains('xmlhttprequest')) {
        return {
          'success': false,
          'message': 'Impossible de se connecter au serveur ($baseUrl). Vérifiez que Spring Boot tourne sur le port $port.',
        };
      }
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  // ==========================================
  // PRODUITS
  // ==========================================

  /// GET /api/getAllProducts
  /// Récupère l'ensemble des produits enregistrés
  static Future<List<Product>> getAllProducts() async {
    final url = Uri.parse('$baseUrl/getAllProducts');

    try {
      debugPrint('[ApiService] GET $url');
      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 12));

      debugPrint('[ApiService] getAllProducts status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is List) {
          return decoded
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } else {
        debugPrint('[ApiService] Erreur getAllProducts (${response.statusCode}): ${response.body}');
      }
      return [];
    } catch (e) {
      debugPrint('[ApiService] Exception getAllProducts: $e');
      rethrow;
    }
  }

  /// POST /api/add
  /// Ajoute un nouveau produit
  static Future<Product> addProduct(Product product) async {
    final url = Uri.parse('$baseUrl/add');

    try {
      debugPrint('[ApiService] POST $url');
      final bodyJson = jsonEncode(product.toJson());
      debugPrint('[ApiService] Payload addProduct: $bodyJson');

      final response = await http
          .post(url, headers: _headers, body: bodyJson)
          .timeout(const Duration(seconds: 15));

      final responseText = utf8.decode(response.bodyBytes);
      debugPrint('[ApiService] addProduct response (${response.statusCode}): $responseText');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(responseText);
        if (decoded is Map<String, dynamic>) {
          return Product.fromJson(decoded);
        }
        return product;
      } else {
        throw Exception('Erreur ${response.statusCode} lors de l\'ajout : $responseText');
      }
    } catch (e) {
      debugPrint('[ApiService] Exception addProduct: $e');
      rethrow;
    }
  }

  /// GET /api/getProducts/{userId}
  /// Récupère la liste des produits publiés par un utilisateur spécifique
  static Future<List<Product>> getProductsByUserId(dynamic userId) async {
    final url = Uri.parse('$baseUrl/getProducts/$userId');

    try {
      debugPrint('[ApiService] GET $url');
      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 12));

      debugPrint('[ApiService] getProductsByUserId status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is List) {
          return decoded
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } else {
        debugPrint('[ApiService] Erreur getProductsByUserId (${response.statusCode}): ${response.body}');
      }
      return [];
    } catch (e) {
      debugPrint('[ApiService] Exception getProductsByUserId: $e');
      rethrow;
    }
  }

  /// PUT /api/update/{id}
  /// Met à jour un produit existant
  static Future<Product> updateProduct(int id, Product product) async {
    final url = Uri.parse('$baseUrl/update/$id');

    try {
      debugPrint('[ApiService] PUT $url');
      final bodyJson = jsonEncode(product.toJson());
      debugPrint('[ApiService] Payload updateProduct: $bodyJson');

      final response = await http
          .put(url, headers: _headers, body: bodyJson)
          .timeout(const Duration(seconds: 15));

      final responseText = utf8.decode(response.bodyBytes);
      debugPrint('[ApiService] updateProduct response (${response.statusCode}): $responseText');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(responseText);
        if (decoded is Map<String, dynamic>) {
          return Product.fromJson(decoded);
        }
        return product;
      } else {
        throw Exception('Erreur ${response.statusCode} lors de la modification : $responseText');
      }
    } catch (e) {
      debugPrint('[ApiService] Exception updateProduct: $e');
      rethrow;
    }
  }

  /// DELETE /api/delete/{id}
  /// Supprime un produit par son ID
  static Future<bool> deleteProduct(int id) async {
    final url = Uri.parse('$baseUrl/delete/$id');

    try {
      debugPrint('[ApiService] DELETE $url');
      final response = await http
          .delete(url, headers: _headers)
          .timeout(const Duration(seconds: 12));

      final responseText = utf8.decode(response.bodyBytes);
      debugPrint('[ApiService] deleteProduct response (${response.statusCode}): $responseText');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Erreur ${response.statusCode} lors de la suppression : $responseText');
      }
    } catch (e) {
      debugPrint('[ApiService] Exception deleteProduct: $e');
      rethrow;
    }
  }
}
