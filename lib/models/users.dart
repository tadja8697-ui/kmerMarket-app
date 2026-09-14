class Users {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String password;

  Users({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'];
    final int parsedId = (idVal is num)
        ? idVal.toInt()
        : int.tryParse(idVal?.toString() ?? '0') ?? 0;

    return Users(
      id: parsedId,
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    };
    if (id > 0) {
      map['id'] = id;
    }
    return map;
  }

  Users copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? password,
  }) {
    return Users(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
    );
  }
}
