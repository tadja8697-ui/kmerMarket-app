// ignore_for_file: non_constant_identifier_names

class Product {
  final int id;
  final String name_p;
  final String desc;
  final double price;
  final String image;
  final String userid;
  final String category;
  final String? sellerName;
  final String? sellerPhone;

  Product({
    required this.id,
    required this.name_p,
    required this.desc,
    required this.price,
    required this.image,
    required this.userid,
    this.category = 'Autre',
    this.sellerName,
    this.sellerPhone,
  });

  String get name => name_p;

  factory Product.fromJson(Map<String, dynamic> json) {
    final userObj = json['user'];
    String parsedUserId = '';
    String? parsedSellerName;
    String? parsedSellerPhone;

    if (userObj is Map<String, dynamic>) {
      parsedUserId = userObj['id']?.toString() ?? '';
      parsedSellerName = userObj['name']?.toString();
      parsedSellerPhone = userObj['phone']?.toString();
    } else if (json['userid'] != null) {
      parsedUserId = json['userid'].toString();
    } else if (json['user_id'] != null) {
      parsedUserId = json['user_id'].toString();
    }

    final idVal = json['id'];
    final int parsedId = (idVal is num)
        ? idVal.toInt()
        : int.tryParse(idVal?.toString() ?? '0') ?? 0;

    final priceVal = json['price'];
    final double parsedPrice = (priceVal is num)
        ? priceVal.toDouble()
        : double.tryParse(priceVal?.toString() ?? '0.0') ?? 0.0;

    return Product(
      id: parsedId,
      name_p: (json['name_p'] ?? json['name'] ?? '').toString(),
      desc: (json['desc'] ?? json['description'] ?? '').toString(),
      price: parsedPrice,
      image: (json['image'] ?? '').toString(),
      userid: parsedUserId,
      category: (json['category'] ?? 'Autre').toString(),
      sellerName: parsedSellerName,
      sellerPhone: parsedSellerPhone,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name_p,
      'name_p': name_p,
      'desc': desc,
      'price': price,
      'image': image,
      'category': category,
    };
    if (id > 0) {
      map['id'] = id;
    }
    final uid = int.tryParse(userid);
    if (uid != null && uid > 0) {
      map['user'] = {'id': uid};
    }
    map['userid'] = userid;
    return map;
  }

  Product copyWith({
    int? id,
    String? name_p,
    String? desc,
    double? price,
    String? image,
    String? userid,
    String? category,
    String? sellerName,
    String? sellerPhone,
  }) {
    return Product(
      id: id ?? this.id,
      name_p: name_p ?? this.name_p,
      desc: desc ?? this.desc,
      price: price ?? this.price,
      image: image ?? this.image,
      userid: userid ?? this.userid,
      category: category ?? this.category,
      sellerName: sellerName ?? this.sellerName,
      sellerPhone: sellerPhone ?? this.sellerPhone,
    );
  }
}
