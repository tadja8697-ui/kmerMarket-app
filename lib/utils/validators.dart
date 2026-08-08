class Validators {
  // --- EMAIL ---
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'email est requis';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  // --- NOM ---
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le nom est requis';
    }
    if (value.trim().length < 2) {
      return 'Le nom est trop court';
    }
    return null;
  }

  // --- TELEPHONE ---
  // Adapté au format camerounais : 9 chiffres, commence souvent par 6
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le numéro de téléphone est requis';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 9) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  // --- MOT DE PASSE ---
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 8) {
      return 'Au moins 8 caractères requis';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Ajoutez au moins une majuscule';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Ajoutez au moins un chiffre';
    }
    return null;
  }

  // --- CONFIRMATION MOT DE PASSE ---
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer le mot de passe';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  // Utilisé pour afficher la checklist en temps réel (majuscule, chiffre, longueur)
  static Map<String, bool> passwordCriteria(String value) {
    return {
      'Au moins 8 caractères': value.length >= 8,
      'Une majuscule': RegExp(r'[A-Z]').hasMatch(value),
      'Un chiffre': RegExp(r'[0-9]').hasMatch(value),
    };
  }
}
