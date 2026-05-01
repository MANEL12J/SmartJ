class User {
  final String? id;
  final String nom;
  final String prenom;
  final String role; // admin | judge | designer
  final String email;

  final String licence;
  final String password;

  User({
    this.id,
    required this.nom,
    required this.prenom,
    required this.role,
    required this.email,

    required this.licence,
    required this.password,
  });

  // Convert User to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'role': role,
      'email': email,
    
    
      'licence': licence,
      'password': password,
    };
  }

  // Create User from Firestore document
  factory User.fromFirestore(Map<String, dynamic> data, String? id) {
    return User(
      id: id,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      role: data['role'] ?? '',
      email: data['email'] ?? '',
    
      licence: data['licence'] ?? '',
      password: data['password'] ?? '',
    );
  }

  // Create copy with updated fields
  User copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? role,
    String? email,
  
    String? licence,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      role: role ?? this.role,
      email: email ?? this.email,
     
      licence: licence ?? this.licence,
      password: password ?? this.password,
    );
  }
}
