
import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  String status;
  String code;
  List<Datum> data;

  Welcome({
    required this.status,
    required this.code,
    required this.data,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
    status: json["status"],
    code: json["code"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "code": code,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {

  Datum({
    required this.id,
    required this.name,
    required this.tags,
    required this.rating,
    required this.discount,
    required this.primaryImage,
    required this.distance,
  });

  int id;   // 5
  String name;   //  "Kake Da Hotel"
  String tags;   // "Chicken, Naan"
  double rating;  // 4.9
  int discount;   // 20
  String primaryImage;  //  "https://theoptimiz.com/restro/public/Resturants/kake-da-hotel.png"
  double distance;   // 3174.53

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
    tags: json["tags"],
    rating: json["rating"]?.toDouble(),
    discount: json["discount"],
    primaryImage: json["primary_image"],
    distance: json["distance"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "tags": tags,
    "rating": rating,
    "discount": discount,
    "primary_image": primaryImage,
    "distance": distance,
  };
}
