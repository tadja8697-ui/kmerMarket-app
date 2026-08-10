class Product{
  final int id;
  final String name_p;
  final String desc;
  final double price;
  final String image;
  final String userid;


  Product({
    required this.id,
    required this.name_p,
    required this.desc,
    required this.price,
    required this.image,
    required this.userid
});

  factory.Product(Map<String, dynamic> json){
    return Product(
      id: json['id'],
      name_p:json['name_p'],
      desc:json['desc'],
      price:(json['price'] as num).toDouble(),
      image:json['image'],
      userid:json['userid'],
    );
  }

  Map<String,dynamic>toJson(){
    return {
      id:'id',
      name_p:'name_p',
      desc:'desc',
      price:'price',
      image:'image',
      userid:'userid',
    };
  }
}